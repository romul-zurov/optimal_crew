object form_main: Tform_main
  Left = 0
  Top = 0
  Caption = #1055#1086#1076#1073#1086#1088' '#1086#1087#1090#1080#1084#1072#1083#1100#1085#1086#1075#1086' '#1101#1082#1080#1087#1072#1078#1072' '#1040#1057'-'#1058#1072#1082#1089#1080
  ClientHeight = 524
  ClientWidth = 978
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  OnClose = FormClose
  OnCreate = FormCreate
  PixelsPerInch = 96
  TextHeight = 13
  object Label1: TLabel
    Left = 8
    Top = 53
    Width = 75
    Height = 13
    Caption = #1040#1076#1088#1077#1089' '#1087#1086#1076#1072#1095#1080':'
  end
  object Label2: TLabel
    Left = 8
    Top = 8
    Width = 51
    Height = 13
    Caption = #1047#1072#1082#1072#1079#1095#1080#1082':'
  end
  object Label3: TLabel
    Left = 16
    Top = 77
    Width = 43
    Height = 13
    Caption = #1069#1082#1080#1087#1072#1078':'
  end
  object Label5: TLabel
    Left = 581
    Top = 77
    Width = 124
    Height = 13
    Caption = #1055#1091#1090#1100' '#1076#1086' '#1072#1076#1088#1077#1089#1072' '#1087#1086#1076#1072#1095#1080':'
  end
  object Label4: TLabel
    Left = 439
    Top = 77
    Width = 90
    Height = 13
    Caption = #1042#1088#1077#1084#1103' '#1076#1086' '#1087#1086#1076#1072#1095#1080':'
  end
  object Label6: TLabel
    Left = 97
    Top = 32
    Width = 35
    Height = 13
    Caption = #1059#1083#1080#1094#1072':'
  end
  object Label7: TLabel
    Left = 479
    Top = 32
    Width = 24
    Height = 13
    Caption = #1044#1086#1084':'
  end
  object Label8: TLabel
    Left = 543
    Top = 32
    Width = 40
    Height = 13
    Caption = #1050#1086#1088#1087#1091#1089':'
  end
  object Label9: TLabel
    Left = 647
    Top = 32
    Width = 90
    Height = 13
    Caption = 'GPS-'#1082#1086#1086#1088#1076#1080#1085#1072#1090#1099':'
  end
  object grid_crews: TStringGrid
    Left = 0
    Top = 96
    Width = 978
    Height = 220
    ColCount = 4
    Ctl3D = False
    FixedCols = 0
    RowCount = 1
    FixedRows = 0
    ParentCtl3D = False
    TabOrder = 0
  end
  object edit_zakaz4ik: TEdit
    Left = 88
    Top = 5
    Width = 777
    Height = 21
    TabOrder = 1
  end
  object edit_ap_street: TEdit
    Left = 88
    Top = 50
    Width = 377
    Height = 21
    TabOrder = 2
  end
  object stbar_main: TStatusBar
    Left = 0
    Top = 505
    Width = 978
    Height = 19
    Panels = <
      item
        Width = 50
      end>
  end
  object DBGrid1: TDBGrid
    Left = 0
    Top = 488
    Width = 978
    Height = 17
    DataSource = datasource_main
    TabOrder = 3
    TitleFont.Charset = DEFAULT_CHARSET
    TitleFont.Color = clWindowText
    TitleFont.Height = -11
    TitleFont.Name = 'Tahoma'
    TitleFont.Style = []
    Visible = False
  end
  object grid_gps: TStringGrid
    Left = 776
    Top = 322
    Width = 202
    Height = 177
    ColCount = 3
    Ctl3D = False
    FixedCols = 0
    RowCount = 1
    FixedRows = 0
    ParentCtl3D = False
    TabOrder = 4
  end
  object grid_order: TStringGrid
    Left = 0
    Top = 322
    Width = 529
    Height = 177
    ColCount = 3
    Ctl3D = False
    FixedCols = 0
    RowCount = 1
    FixedRows = 0
    ParentCtl3D = False
    TabOrder = 5
  end
  object Button1: TButton
    Left = 871
    Top = 3
    Width = 99
    Height = 25
    Caption = 'Go!'
    TabOrder = 8
    OnClick = Button1Click
  end
  object edit_ap_house: TEdit
    Left = 471
    Top = 50
    Width = 58
    Height = 21
    TabOrder = 9
  end
  object edit_ap_korpus: TEdit
    Left = 535
    Top = 50
    Width = 58
    Height = 21
    TabOrder = 10
  end
  object edit_ap_gps: TEdit
    Left = 639
    Top = 50
    Width = 226
    Height = 21
    TabOrder = 11
  end
  object browser: TWebBrowser
    Left = 543
    Top = 344
    Width = 410
    Height = 155
    TabOrder = 7
    OnDocumentComplete = browserDocumentComplete
    ControlData = {
      4C000000602A0000051000000000000000000000000000000000000000000000
      000000004C000000000000000000000001000000E0D057007335CF11AE690800
      2B2E126208000000000000004C0000000114020000000000C000000000000046
      8000000000000000000000000000000000000000000000000000000000000000
      00000000000000000100000000000000000000000000000000000000}
  end
  object cb_real_base: TCheckBox
    Left = 873
    Top = 52
    Width = 97
    Height = 17
    Caption = 'cb_real_base'
    TabOrder = 12
  end
  object db_main: TIBDatabase
    LoginPrompt = False
    Left = 264
    Top = 472
  end
  object ta_main: TIBTransaction
    DefaultDatabase = db_main
    Left = 528
    Top = 472
  end
  object datasource_main: TDataSource
    Left = 360
    Top = 472
  end
  object ibquery_main: TIBQuery
    Database = db_main
    Transaction = ta_main
    DataSource = datasource_main
    Left = 464
    Top = 472
  end
end
