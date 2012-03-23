object form_main: Tform_main
  Left = 0
  Top = 0
  Caption = #1055#1086#1076#1073#1086#1088' '#1086#1087#1090#1080#1084#1072#1083#1100#1085#1086#1075#1086' '#1101#1082#1080#1087#1072#1078#1072' '#1040#1057'-'#1058#1072#1082#1089#1080
  ClientHeight = 431
  ClientWidth = 845
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
  object stbar_main: TStatusBar
    Left = 0
    Top = 412
    Width = 845
    Height = 19
    Panels = <
      item
        Width = 50
      end>
    ExplicitTop = 399
    ExplicitWidth = 838
  end
  object GridPanel_main: TGridPanel
    AlignWithMargins = True
    Left = 3
    Top = 3
    Width = 839
    Height = 406
    Align = alClient
    ColumnCollection = <
      item
        Value = 100.000000000000000000
      end>
    ControlCollection = <
      item
        Column = 0
        Control = panel_ap
        Row = 0
      end
      item
        Column = 0
        Control = GridPanel_grids
        Row = 1
      end>
    RowCollection = <
      item
        SizeStyle = ssAuto
        Value = 53.703703703703710000
      end
      item
        Value = 100.000000000000000000
      end>
    TabOrder = 1
    ExplicitLeft = 8
    ExplicitTop = 8
    ExplicitWidth = 822
    ExplicitHeight = 273
    object panel_ap: TPanel
      AlignWithMargins = True
      Left = 5
      Top = 5
      Width = 829
      Height = 73
      Margins.Left = 4
      Margins.Top = 4
      Margins.Right = 4
      Margins.Bottom = 4
      Align = alTop
      TabOrder = 0
      ExplicitWidth = 73
      ExplicitHeight = 812
      object Label2: TLabel
        Left = 1
        Top = 6
        Width = 51
        Height = 13
        Caption = #1047#1072#1082#1072#1079#1095#1080#1082':'
      end
      object Label1: TLabel
        Left = 1
        Top = 51
        Width = 75
        Height = 13
        Caption = #1040#1076#1088#1077#1089' '#1087#1086#1076#1072#1095#1080':'
      end
      object Label6: TLabel
        Left = 90
        Top = 34
        Width = 35
        Height = 13
        Caption = #1059#1083#1080#1094#1072':'
      end
      object Label7: TLabel
        Left = 432
        Top = 36
        Width = 24
        Height = 13
        Caption = #1044#1086#1084':'
      end
      object Label8: TLabel
        Left = 496
        Top = 36
        Width = 40
        Height = 13
        Caption = #1050#1086#1088#1087#1091#1089':'
      end
      object Label9: TLabel
        Left = 590
        Top = 30
        Width = 90
        Height = 13
        Caption = 'GPS-'#1082#1086#1086#1088#1076#1080#1085#1072#1090#1099':'
      end
      object Button1: TButton
        Left = 756
        Top = 1
        Width = 64
        Height = 25
        Caption = 'Go!'
        TabOrder = 0
        OnClick = Button1Click
      end
      object cb_real_base: TCheckBox
        Left = 678
        Top = 7
        Width = 64
        Height = 17
        Caption = 'Release'
        TabOrder = 1
        OnClick = cb_real_baseClick
      end
      object edit_zakaz4ik: TEdit
        Left = 81
        Top = 3
        Width = 577
        Height = 21
        TabOrder = 2
      end
      object edit_ap_street: TEdit
        Left = 81
        Top = 49
        Width = 328
        Height = 21
        TabOrder = 3
      end
      object edit_ap_house: TEdit
        Left = 424
        Top = 50
        Width = 58
        Height = 21
        TabOrder = 4
      end
      object edit_ap_korpus: TEdit
        Left = 488
        Top = 50
        Width = 58
        Height = 21
        TabOrder = 5
      end
      object edit_ap_gps: TEdit
        Left = 582
        Top = 48
        Width = 235
        Height = 21
        TabOrder = 6
      end
    end
    object GridPanel_grids: TGridPanel
      Left = 1
      Top = 82
      Width = 837
      Height = 323
      Align = alClient
      ColumnCollection = <
        item
          Value = 79.950962864585980000
        end
        item
          Value = 20.049037135414000000
        end>
      ControlCollection = <
        item
          Column = 0
          Control = GroupBox_order
          Row = 0
        end
        item
          Column = 1
          Control = GroupBox_crew
          Row = 0
        end>
      RowCollection = <
        item
          Value = 100.000000000000000000
        end>
      TabOrder = 1
      ExplicitLeft = 102
      ExplicitTop = 96
      ExplicitWidth = 618
      ExplicitHeight = 207
      object GroupBox_order: TGroupBox
        Left = 1
        Top = 1
        Width = 667
        Height = 321
        Align = alClient
        Caption = #1058#1077#1082#1091#1097#1080#1077' '#1079#1072#1082#1072#1079#1099':'
        TabOrder = 0
        ExplicitLeft = 85
        ExplicitTop = 32
        ExplicitWidth = 337
        ExplicitHeight = 173
        object grid_order: TStringGrid
          AlignWithMargins = True
          Left = 5
          Top = 18
          Width = 657
          Height = 298
          Align = alClient
          ColCount = 3
          Ctl3D = False
          FixedCols = 0
          RowCount = 1
          FixedRows = 0
          ParentCtl3D = False
          TabOrder = 0
          ExplicitLeft = 64
          ExplicitTop = 51
          ExplicitWidth = 217
          ExplicitHeight = 39
        end
      end
      object GroupBox_crew: TGroupBox
        Left = 668
        Top = 1
        Width = 168
        Height = 321
        Align = alClient
        Caption = #1044#1086#1089#1090#1091#1087#1085#1099#1077' '#1101#1082#1080#1087#1072#1078#1080':'
        TabOrder = 1
        ExplicitLeft = 760
        ExplicitTop = 176
        ExplicitWidth = 185
        ExplicitHeight = 105
        object grid_crews: TStringGrid
          AlignWithMargins = True
          Left = 5
          Top = 18
          Width = 158
          Height = 298
          Align = alClient
          ColCount = 4
          Ctl3D = False
          FixedCols = 0
          RowCount = 1
          FixedRows = 0
          ParentCtl3D = False
          TabOrder = 0
          ExplicitLeft = -121
          ExplicitTop = 27
          ExplicitWidth = 289
          ExplicitHeight = 55
        end
      end
    end
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
