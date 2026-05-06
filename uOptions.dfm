object frmOptions: TfrmOptions
  Tag = 99
  Left = 0
  Top = 0
  BorderIcons = [biSystemMenu]
  BorderStyle = bsSingle
  Caption = #50741#49496
  ClientHeight = 294
  ClientWidth = 329
  Color = clBtnFace
  Font.Charset = ANSI_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  KeyPreview = True
  Position = poOwnerFormCenter
  OnKeyDown = FormKeyDown
  OnShow = FormShow
  TextHeight = 13
  object btnCancel: TsBitBtn
    Left = 249
    Top = 269
    Width = 80
    Height = 25
    Caption = #52712#49548'(&C)'
    ModalResult = 2
    TabOrder = 2
    SkinData.SkinSection = 'SPEEDBUTTON'
  end
  object btnOK: TsBitBtn
    Left = 164
    Top = 269
    Width = 80
    Height = 25
    Caption = #54869#51064'(&O)'
    ModalResult = 1
    TabOrder = 1
    OnClick = btnOKClick
    SkinData.SkinSection = 'SPEEDBUTTON'
  end
  object tvOptions: TsTreeView
    Left = 0
    Top = 8
    Width = 121
    Height = 255
    DoubleBuffered = True
    Indent = 19
    ParentDoubleBuffered = False
    ReadOnly = True
    ShowLines = False
    ShowRoot = False
    TabOrder = 0
    OnChange = tvOptionsChange
  end
  object pnlOptions: TsPanel
    Left = 127
    Top = 0
    Width = 202
    Height = 263
    Align = alCustom
    BevelOuter = bvNone
    TabOrder = 3
    object grpGeneral: TsGroupBox
      Tag = 1
      Left = 0
      Top = 0
      Width = 202
      Height = 263
      Align = alClient
      TabOrder = 0
      object lblByteEncoding: TsLabel
        Left = 8
        Top = 13
        Width = 101
        Height = 13
        Caption = #48148#51060#53944' '#44228#49328' '#48169#49885'(&B):'
        FocusControl = cbByteEncoding
      end
      object cbByteEncoding: TsComboBox
        Left = 8
        Top = 30
        Width = 121
        Height = 21
        TabOrder = 1
        Style = csDropDownList
      end
      object chkCloseOnEsc: TsCheckBox
        Left = 3
        Top = 57
        Width = 147
        Height = 17
        Caption = '&Esc '#53412#47196' '#54532#47196#44536#47016' '#51333#47308
        TabOrder = 0
      end
    end
  end
  object sSkinProvider: TsSkinProvider
    ShowAppIcon = False
    AddedTitle.Font.Charset = ANSI_CHARSET
    AddedTitle.Font.Color = clNone
    AddedTitle.Font.Height = -11
    AddedTitle.Font.Name = 'Tahoma'
    AddedTitle.Font.Style = [fsBold]
    AddedTitle.Text = #50741#49496
    AddedTitle.ShowMainCaption = False
    CaptionAlignment = taCenter
    SkinData.SkinSection = 'FORM'
    TitleButtons = <>
    Left = 8
    Top = 8
  end
end
