unit uAmdGpu;

interface

uses
  uTypes,
  adl_defines, adl_sdk, adl_structures;

type
  TADL_MAIN_CONTROL_CREATE = function(param1: ADL_MAIN_MALLOC_CALLBACK; param2: Integer): Integer; cdecl;
  TADL_MAIN_CONTROL_DESTROY = function: Integer; cdecl;
  TADL_FAN_CONTROL_GET = function(pContext: Pointer; iAdapterIndex: Integer; var FanControl: ADLODNFanControl): Integer; cdecl;
  TADL_FAN_CONTROL_SET = function(pContext: Pointer; iAdapterIndex: Integer; PFanControl: Pointer): Integer; cdecl;
  TADL_OVERDRIVE5_TEMPERATURE_GET = function (iAdapterIndex, iThermalControllerIndex : integer; var lpTemperature : ADLTemperature) : integer; cdecl;
  TADL_OVERDRIVE5_FANSPEED_GET = function (iAdapterIndex, iThermalControllerIndex: integer; var lpFanSpeedValue: ADLFanSpeedValue): integer; cdecl;
  TADL_ADAPTER_NUMBEROFADAPTERS_GET = function (var lpNumAdapters: integer): integer; cdecl;
  TADL_ADAPTER_ACTIVE_GET = function(iAdapterIndex: integer; var lpStatus: Integer): Integer; cdecl;
  TADL_ADAPTER_ADAPTERINFO_GET = function(AInfo : Pointer; iInputSize: Integer): integer; cdecl;

  TAmdGpu = class(TGpu)
  private
  protected
    function GetFanSpeed(idx: Integer): Integer; override;
    function GetTemperature(idx: Integer): Integer; override;
    function GetTargetTemperature(idx: Integer): Integer; override;
    procedure SetTargetTemperature(idx: Integer; ATargetTemp: Integer); override;
    function GetAdapterActive(idx: Integer): Boolean; override;
  public
    class function GetNumberOfAdapters(): Integer; override;
    class function GetAdapterInfo(idx: Integer): LPAdapterInfo; override;
    constructor Create();
    destructor Destroy(); override;
  end;

var
  AmdCardsPresent: Boolean;

implementation

uses
  Windows;

const
  ATI_DLL = 'atiadlxy.dll';

var
  hDLL: hModule;
  ADL_context: Pointer;
  ADL_Fan_Control_Get: TADL_Fan_Control_Get;
  ADL_Fan_Control_Set: TADL_Fan_Control_Set;
  ADL_Overdrive5_Temperature_Get: TADL_OVERDRIVE5_TEMPERATURE_GET;
  ADL_Adapter_NumberOfAdapters_Get: TADL_ADAPTER_NUMBEROFADAPTERS_GET;
  ADL_Adapter_Active_Get: TADL_ADAPTER_ACTIVE_GET;
  ADL_Adapter_AdapterInfo_Get: TADL_ADAPTER_ADAPTERINFO_GET;
  ADL_Overdrive5_FanSpeed_Get: TADL_OVERDRIVE5_FANSPEED_GET;

{ TAmdGpu }

constructor TAmdGpu.Create();
begin
  inherited;
end;

destructor TAmdGpu.Destroy();
begin
  inherited;
end;

function TAmdGpu.GetAdapterActive(idx: Integer): Boolean;
var
  status: Integer;
begin
  ADL_Adapter_Active_Get(idx, status);
  Result := status = ADL_OK;
end;

class function TAmdGpu.GetAdapterInfo(idx: Integer): LPAdapterInfo;
var
  size: Integer;
  ADL_PInfo: LPAdapterInfo;
begin
  size := sizeof(AdapterInfo) * GetNumberOfAdapters();
  ADL_PInfo := AllocMem(size);
  ADL_Adapter_AdapterInfo_Get(ADL_PInfo, size);
  for size := 1 to idx do
    inc(ADL_PInfo);
  Result := ADL_PInfo;
end;

function TAmdGpu.GetFanSpeed(idx: Integer): Integer;
var
  fanSpeed: ADLFanSpeedValue;
begin
  fanSpeed.iSize := sizeof(fanSpeed);
  ADL_Overdrive5_Fanspeed_Get(idx, 0, fanSpeed);
  Result := fanSpeed.iFanSpeed;
end;

class function TAmdGpu.GetNumberOfAdapters(): Integer;
begin
  ADL_Adapter_NumberOfAdapters_Get(Result);
end;

function TAmdGpu.GetTemperature(idx: Integer): Integer;
var
  temperature: ADLTemperature;
begin
  temperature.iSize := sizeof(temperature);
  ADL_Overdrive5_Temperature_Get(idx, 0, temperature);
  Result := Round(temperature.iTemperature / 1000);
end;

function TAmdGpu.GetTargetTemperature(idx: Integer): Integer;
var
  fan: ADLODNFanControl;
begin
  ADL_Fan_Control_Get(nil, idx, fan);
  Result := fan.iTargetTemperature;
end;

procedure TAmdGpu.SetTargetTemperature(idx: Integer; ATargetTemp: Integer);
var
  fan: ADLODNFanControl;
begin
  ADL_Fan_Control_Get(nil, idx, fan);
  fan.iTargetTemperature := ATargetTemp;
  ADL_Fan_Control_Set(nil, idx, @fan);
end;

var
  ADL_Main_Control_Create: TADL_MAIN_CONTROL_CREATE;
  ADL_Main_Control_Destroy: TADL_MAIN_CONTROL_DESTROY;

function ADL_Main_Memory_Alloc(iSize: Integer): Pointer; stdcall;
begin
  Result := AllocMem(iSize);
end;

initialization
begin
  AmdCardsPresent := False;
  try
    hDLL := LoadLibrary(ATI_DLL);
    if hDLL <> 0 then
    begin
      ADL_Main_Control_Create := GetProcAddress(hDLL, 'ADL_Main_Control_Create');
      if Assigned(ADL_Main_Control_Create) then
      begin
        ADL_context := @ADL_Main_Memory_Alloc;
        AmdCardsPresent := ADL_Main_Control_Create(ADL_context, 1) = ADL_OK;
      end;
    end;
    ADL_Fan_Control_Get := GetProcAddress(hDLL, 'ADL2_OverdriveN_FanControl_Get');
    ADL_Fan_Control_Set := GetProcAddress(hDLL, 'ADL2_OverdriveN_FanControl_Set');
    ADL_Adapter_NumberOfAdapters_Get := GetProcAddress(hDLL, 'ADL_Adapter_NumberOfAdapters_Get');
    ADL_Overdrive5_Temperature_Get := GetProcAddress(hDLL, 'ADL_Overdrive5_Temperature_Get');
    ADL_Adapter_AdapterInfo_Get := GetProcAddress(hDLL, 'ADL_Adapter_AdapterInfo_Get');
    ADL_Adapter_Active_Get := GetProcAddress(hDLL, 'ADL_Adapter_Active_Get');
    ADL_Overdrive5_Fanspeed_Get := GetProcAddress(hDLL, 'ADL_Overdrive5_FanSpeed_Get');
  except
  end;
end;

finalization
begin
  if AmdCardsPresent then
  begin
    ADL_Main_Control_Destroy := GetProcAddress(hDLL, 'ADL_Main_Control_Destroy');
    if Assigned(ADL_Main_Control_Destroy) then
      ADL_Main_Control_Destroy();
  end;
end;

end.
