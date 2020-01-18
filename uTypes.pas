unit uTypes;

interface

uses
  adl_structures,
  Contnrs;

type
  TUser = class(TObject)
  public
    id: Integer;
    Name: String;
    Password: String;
    Email: String;
    Phone: String;
    EthAddress: String;
    credits: Integer;
  end;

  TAlgorithm = class(TObject)
  public
    id: Integer;
    Name: String;
  end;

  TProgram = class(TObject)
  public
    id: Integer;
    Algorithm: TAlgorithm;
    Title: String;
    Description: String;
    Path: String;
  end;

  TSetting = class(TObject)
  public
    id: Integer;
    AProgram: TProgram;
    Name: String;
    Parameters: String;
  end;

  TNotifyType = class(TObject)
  public
    id: Integer;
    Name: String;
  end;

  TNotification = class(TObject)
  public
    id: Integer;
    NotifyType: TNotifyType;
    Email: Boolean;
    Phone: Boolean;
  end;

  TCommand = class(TObject)
  public
    id: Integer;
    Name: String;
  end;

  TOverClock = class(TObject)
  public
    id: Integer;
    Core: String;
    Memory: String;
    Voltage: Integer;
    Power: Integer;
    Temperature: Integer;
    Fan: Integer;
  end;

  TGpu = class(TObject)
  private
  protected
    function GetFanSpeed(idx: Integer): Integer; virtual; abstract;
    function GetTemperature(idx: Integer): Integer; virtual; abstract;
    function GetTargetTemperature(idx: Integer): Integer; virtual; abstract;
    procedure SetTargetTemperature(idx: Integer; ATargetTemp: Integer); virtual; abstract;
    class function GetNumberOfAdapters(): Integer; virtual; abstract;
    class function GetAdapterInfo(idx: Integer): LPAdapterInfo; virtual; abstract;
    function GetAdapterActive(idx: Integer): Boolean; virtual; abstract;
  public
    id: Integer;
    idx: Integer;
    BusNumber: Integer;
    Overclock: TOverclock;
    Name: String;
    Vendor: String;
    Memory: String;
    Identifier: String;
    Speed: String;
    Temperature: Integer;
    constructor Create();
    destructor Destroy(); override;
  end;

  TMiner = class(TObject)
  public
    id: Integer;
    statusId: Integer;
    Gpus: TObjectList;
    Settings: TSetting;
    Name: String;
    Notes: String;
    MotherboardId: String;
    Active: Boolean;
    Online: Boolean;
    TotalSpeed: String;
    LastPing: TDateTime;
    RestartCount: Integer;
    function GetGpuByID(AID: Integer): TGpu;
    constructor Create();
    destructor Destroy(); override;
  end;

  TJob = class(TObject)
  public
    id: Integer;
    Miner: TMiner;
    Command: TCommand;
    Parameters: String;
    Active: Boolean;
  end;

implementation

uses
  Classes,
  SysUtils;

{$REGION 'TMiner'}

constructor TMiner.Create();
begin
  Gpus := TObjectList.Create(True);
end;

destructor TMiner.Destroy();
begin
  FreeAndNil(Gpus);
  inherited;
end;

function TMiner.GetGpuByID(AID: Integer): TGpu;
var
  i: Integer;
begin
  Result := nil;
  for i := 0 to Gpus.Count - 1 do
    if TGpu(Gpus[i]).id = AID then
    begin
      Result := TGpu(Gpus[i]);
      Exit;
    end;
end;

{$ENDREGION}

{$REGION 'TGpu'}

constructor TGpu.Create();
begin
  Overclock := TOverClock.Create();
end;

destructor TGpu.Destroy();
begin
  FreeAndNil(Overclock);
  inherited;
end;

{$ENDREGION}

end.

