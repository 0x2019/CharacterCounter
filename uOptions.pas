unit uOptions;

interface

uses
  Winapi.Windows, System.Classes, Vcl.Buttons, Vcl.ComCtrls, Vcl.Controls,
  Vcl.ExtCtrls, Vcl.Forms, Vcl.StdCtrls, sSkinProvider, sBitBtn, sCheckBox,
  sPanel, sTreeView, sGroupBox, uMain;

const
  SectionGeneral = 1;

type
  TfrmOptions = class(TForm)
    btnCancel: TsBitBtn;
    btnOK: TsBitBtn;
    sSkinProvider: TsSkinProvider;
    tvOptions: TsTreeView;
    pnlOptions: TsPanel;
    grpGeneral: TsGroupBox;
    chkUseCP949: TsCheckBox;
    procedure btnOKClick(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure tvOptionsChange(Sender: TObject; Node: TTreeNode);
    procedure FormKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
  private
    procedure InitTree;
    procedure SetSection(const Section: Integer);
    procedure LoadOptions(const F: TfrmMain);
    procedure SaveOptions(const F: TfrmMain);
  public
    { Public declarations }
  end;

var
  frmOptions: TfrmOptions;

implementation

{$R *.dfm}

uses
  uAppController, uAppStrings;

procedure TfrmOptions.InitTree;
var
  Node: TTreeNode;
begin
  tvOptions.Items.Clear;

  Node := tvOptions.Items.Add(nil, SOptionsNodeGeneral);
  Node.Data := Pointer(NativeInt(SectionGeneral));

  tvOptions.FullExpand;
end;

procedure TfrmOptions.SetSection(const Section: Integer);
var
  i: Integer;
  Control: TControl;
begin
  for i := 0 to pnlOptions.ControlCount - 1 do
  begin
    Control := pnlOptions.Controls[i];
    if Control is TsGroupBox then
      Control.Visible := Control.Tag = Section;
  end;
end;

procedure TfrmOptions.LoadOptions(const F: TfrmMain);
begin
  if F = nil then Exit;

// General
  chkUseCP949.Checked := F.FUseCP949;
end;

procedure TfrmOptions.SaveOptions(const F: TfrmMain);
begin
  if F = nil then Exit;

// General
  F.FUseCP949 := chkUseCP949.Checked;
  AppController_CP949Encoding(F);
end;

procedure TfrmOptions.tvOptionsChange(Sender: TObject; Node: TTreeNode);
begin
  if (Node <> nil) and (Node.Data <> nil) then
    SetSection(NativeInt(Node.Data));
end;

procedure TfrmOptions.btnOKClick(Sender: TObject);
begin
  if frmMain = nil then Exit;

  if (tvOptions.Selected <> nil) and (tvOptions.Selected.Data <> nil) then
    frmMain.FOptionsSection := NativeInt(tvOptions.Selected.Data);

  SaveOptions(frmMain);
  ModalResult := mrOk;
end;

procedure TfrmOptions.FormKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
begin
  if Key = VK_ESCAPE then
  begin
    Key := 0;
    btnCancel.Click;
  end
  else if Key = VK_RETURN then
  begin
    Key := 0;
    btnOK.Click;
  end;
end;

procedure TfrmOptions.FormShow(Sender: TObject);
var
  SelectedSection: Integer;
  ItemIndex: Integer;
begin
  InitTree;

  if frmMain = nil then Exit;

  if frmMain.FOptionsSection = 0 then
    SelectedSection := SectionGeneral
  else
    SelectedSection := frmMain.FOptionsSection;

  tvOptions.Selected := nil;
  for ItemIndex := 0 to tvOptions.Items.Count - 1 do
  begin
    if NativeInt(tvOptions.Items[ItemIndex].Data) = SelectedSection then
    begin
      tvOptions.Selected := tvOptions.Items[ItemIndex];
      Break;
    end;
  end;

  if (tvOptions.Selected = nil) and (tvOptions.Items.Count > 0) then
    tvOptions.Selected := tvOptions.Items[0];

  LoadOptions(frmMain);
end;

end.
