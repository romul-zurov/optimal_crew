object form_main: Tform_main
  Left = 0
  Top = 0
  Caption = #1055#1086#1076#1073#1086#1088' '#1086#1087#1090#1080#1084#1072#1083#1100#1085#1086#1075#1086' '#1101#1082#1080#1087#1072#1078#1072' '#1040#1057'-'#1058#1072#1082#1089#1080
  ClientHeight = 536
  ClientWidth = 580
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  OnCreate = FormCreate
  PixelsPerInch = 96
  TextHeight = 13
  object Label1: TLabel
    Left = 8
    Top = 40
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
    Left = 320
    Top = 77
    Width = 124
    Height = 13
    Caption = #1055#1091#1090#1100' '#1076#1086' '#1072#1076#1088#1077#1089#1072' '#1087#1086#1076#1072#1095#1080':'
  end
  object Label4: TLabel
    Left = 136
    Top = 77
    Width = 90
    Height = 13
    Caption = #1042#1088#1077#1084#1103' '#1076#1086' '#1087#1086#1076#1072#1095#1080':'
  end
  object grid_crews: TStringGrid
    Left = 0
    Top = 96
    Width = 580
<<<<<<< HEAD
    Height = 210
=======
    Height = 41
>>>>>>> 4ebb61dd2e0a9c3fab2e4d7fc3b8b1bf80a519ce
    ColCount = 3
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
    Width = 486
    Height = 21
    TabOrder = 1
  end
  object edit_adres: TEdit
    Left = 88
    Top = 37
    Width = 486
    Height = 21
    TabOrder = 2
  end
  object stbar_main: TStatusBar
    Left = 0
    Top = 517
    Width = 580
    Height = 19
    Panels = <
      item
        Width = 50
      end>
    ExplicitTop = 399
  end
  object DBGrid1: TDBGrid
    Left = 0
<<<<<<< HEAD
    Top = 312
    Width = 580
    Height = 205
=======
    Top = 143
    Width = 580
    Height = 374
>>>>>>> 4ebb61dd2e0a9c3fab2e4d7fc3b8b1bf80a519ce
    Align = alBottom
    DataSource = datasource_main
    TabOrder = 4
    TitleFont.Charset = DEFAULT_CHARSET
    TitleFont.Color = clWindowText
    TitleFont.Height = -11
    TitleFont.Name = 'Tahoma'
    TitleFont.Style = []
  end
  object db_main: TIBDatabase
    Params.Strings = (
      'user_name=SYSDBA'
      'password=masterkey'
      'lc_ctype=WIN1251')
    LoginPrompt = False
    Left = 136
    Top = 416
  end
  object ta_main: TIBTransaction
    DefaultDatabase = db_main
    Left = 392
    Top = 400
  end
  object dataset_main: TIBDataSet
    Database = db_main
    Transaction = ta_main
    Left = 304
    Top = 360
  end
  object datasource_main: TDataSource
    DataSet = dataset_main
    Left = 208
    Top = 392
  end
end
