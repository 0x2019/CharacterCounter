unit uAppMenu;

interface

uses
  Vcl.Forms, uMain,

  uForms;

procedure AppMenu_AlwaysOnTop(F: TfrmMain);

implementation

procedure AppMenu_AlwaysOnTop(F: TfrmMain);
begin
  if F = nil then Exit;
  F.miAlwaysOnTop.Checked := not F.miAlwaysOnTop.Checked;
  UI_SetAlwaysOnTop(F, F.miAlwaysOnTop.Checked);
end;

end.

