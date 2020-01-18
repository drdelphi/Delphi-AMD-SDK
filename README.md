# Delphi-AMD-SDK

AMD SDK translated for Delphi

Usage example:

uses adl_structures, uAmdGpu;

procedure DetectAmdCards();
var
  i, n: Integer;
  g: TAmdGpu;
  adapterInfo: LPAdapterInfo;
begin
  if not AmdCardsPresent then
    Exit;
  n := TAmdGpu.GetNumberOfAdapters();
  for i := 0 to n - 1 do
  begin
    adapterInfo := TAmdGpu.GetAdapterInfo(i);
    g := GetAmdGpuByIDX(adapterInfo.iDeviceNumber);
    if g <> nil then
      continue;
    Memo1.Lines.Add('Bus ' + IntToStr(adapterInfo.iBusNumber) + ' - ' +
      String(adapterInfo.strAdapterName));
  end;
end;
