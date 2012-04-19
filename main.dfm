object form_main: Tform_main
  Left = 0
  Top = 0
  Caption = #1055#1086#1076#1073#1086#1088' '#1086#1087#1090#1080#1084#1072#1083#1100#1085#1086#1075#1086' '#1101#1082#1080#1087#1072#1078#1072' '#1040#1057'-'#1058#1072#1082#1089#1080
  ClientHeight = 381
  ClientWidth = 770
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
  object GridPanel_main: TGridPanel
    AlignWithMargins = True
    Left = 3
    Top = 3
    Width = 764
    Height = 375
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
      end
      item
        Column = 0
        Control = stbar_main
        Row = 2
      end>
    RowCollection = <
      item
        SizeStyle = ssAuto
        Value = 100.000000000000000000
      end
      item
        Value = 100.000000000000000000
      end
      item
        SizeStyle = ssAuto
        Value = 30.000000000000000000
      end
      item
        SizeStyle = ssAuto
      end>
    TabOrder = 0
    object panel_ap: TPanel
      AlignWithMargins = True
      Left = 5
      Top = 5
      Width = 754
      Height = 42
      Margins.Left = 4
      Margins.Top = 4
      Margins.Right = 4
      Margins.Bottom = 4
      Align = alTop
      AutoSize = True
      TabOrder = 0
      DesignSize = (
        754
        42)
      object Label2: TLabel
        Left = 164
        Top = 1
        Width = 51
        Height = 13
        Caption = #1047#1072#1082#1072#1079#1095#1080#1082':'
        Visible = False
      end
      object Label1: TLabel
        Left = 2
        Top = 1
        Width = 75
        Height = 13
        Caption = #1040#1076#1088#1077#1089' '#1087#1086#1076#1072#1095#1080':'
        Visible = False
      end
      object Label6: TLabel
        Left = 33
        Top = 1
        Width = 35
        Height = 13
        Caption = #1059#1083#1080#1094#1072':'
        Visible = False
      end
      object Label7: TLabel
        Left = 63
        Top = 1
        Width = 24
        Height = 13
        Caption = #1044#1086#1084':'
        Visible = False
      end
      object Label8: TLabel
        Left = 63
        Top = 1
        Width = 40
        Height = 13
        Caption = #1050#1086#1088#1087#1091#1089':'
        Visible = False
      end
      object Label9: TLabel
        Left = 93
        Top = 1
        Width = 90
        Height = 13
        Caption = 'GPS-'#1082#1086#1086#1088#1076#1080#1085#1072#1090#1099':'
        Visible = False
      end
      object Button1: TButton
        Left = 609
        Top = 6
        Width = 125
        Height = 25
        Anchors = [akTop, akRight]
        Caption = #1054#1073#1085#1086#1074#1080#1090#1100' '#1089#1087#1080#1089#1086#1082
        TabOrder = 0
        OnClick = Button1Click
      end
      object cb_real_base: TCheckBox
        Left = 582
        Top = 10
        Width = 30
        Height = 17
        Anchors = [akTop, akRight]
        Caption = 'R'
        TabOrder = 1
        OnClick = cb_real_baseClick
      end
      object edit_zakaz4ik: TEdit
        Left = 119
        Top = 20
        Width = 18
        Height = 21
        TabOrder = 2
        Visible = False
      end
      object edit_ap_street: TEdit
        Left = 2
        Top = 20
        Width = 25
        Height = 21
        TabOrder = 3
        Visible = False
      end
      object edit_ap_house: TEdit
        Left = 33
        Top = 20
        Width = 24
        Height = 21
        TabOrder = 4
        Visible = False
      end
      object edit_ap_korpus: TEdit
        Left = 63
        Top = 20
        Width = 24
        Height = 21
        TabOrder = 5
        Visible = False
      end
      object edit_ap_gps: TEdit
        Left = 93
        Top = 20
        Width = 20
        Height = 21
        TabOrder = 6
        Visible = False
      end
      object button_show_sl: TButton
        Left = 315
        Top = 6
        Width = 75
        Height = 25
        Anchors = [akTop, akRight]
        Caption = 'Debug'
        TabOrder = 7
        OnClick = button_show_slClick
      end
      object Button_show_order: TButton
        Left = 462
        Top = 6
        Width = 114
        Height = 25
        Anchors = [akTop, akRight]
        Caption = #1055#1086#1076#1088#1086#1073#1085#1086#1089#1090#1080' '#1079#1072#1082#1072#1079#1072
        TabOrder = 8
        OnClick = Button_show_orderClick
      end
    end
    object GridPanel_grids: TGridPanel
      Left = 1
      Top = 51
      Width = 762
      Height = 304
      Align = alClient
      ColumnCollection = <
        item
          Value = 100.000000000000000000
        end
        item
          SizeStyle = ssAbsolute
          Value = 250.000000000000000000
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
      object GroupBox_order: TGroupBox
        Left = 1
        Top = 1
        Width = 510
        Height = 302
        Align = alClient
        Caption = #1047#1072#1082#1072#1079#1099':'
        TabOrder = 0
        object PageControl_orders: TPageControl
          Left = 2
          Top = 15
          Width = 506
          Height = 285
          ActivePage = TabSheet_current
          Align = alClient
          TabOrder = 0
          object TabSheet_current: TTabSheet
            Caption = #1058#1077#1082#1091#1097#1080#1077':'
            object grid_order_current: TStringGrid
              AlignWithMargins = True
              Left = 3
              Top = 3
              Width = 492
              Height = 251
              Align = alClient
              ColCount = 3
              Ctl3D = False
              DefaultRowHeight = 16
              FixedCols = 0
              RowCount = 1
              FixedRows = 0
              ParentCtl3D = False
              TabOrder = 0
              OnDblClick = grid_order_currentDblClick
            end
          end
          object TabSheet_prior: TTabSheet
            Caption = #1055#1088#1077#1076#1074#1072#1088#1080#1090#1077#1083#1100#1085#1099#1077
            ImageIndex = 1
            object grid_order_prior: TStringGrid
              AlignWithMargins = True
              Left = 3
              Top = 3
              Width = 492
              Height = 251
              Align = alClient
              ColCount = 3
              Ctl3D = False
              DefaultRowHeight = 16
              FixedCols = 0
              RowCount = 1
              FixedRows = 0
              ParentCtl3D = False
              TabOrder = 0
              OnDblClick = grid_order_currentDblClick
            end
          end
        end
      end
      object GroupBox_crew: TGroupBox
        Left = 511
        Top = 1
        Width = 250
        Height = 302
        Align = alClient
        Caption = #1044#1086#1089#1090#1091#1087#1085#1099#1077' '#1101#1082#1080#1087#1072#1078#1080':'
        TabOrder = 1
        object grid_crews: TStringGrid
          AlignWithMargins = True
          Left = 5
          Top = 18
          Width = 240
          Height = 279
          Align = alClient
          ColCount = 4
          Ctl3D = False
          DefaultRowHeight = 16
          FixedCols = 0
          RowCount = 1
          FixedRows = 0
          ParentCtl3D = False
          TabOrder = 0
          OnDblClick = grid_crewsDblClick
        end
      end
    end
    object stbar_main: TStatusBar
      Left = 1
      Top = 355
      Width = 762
      Height = 19
      Align = alClient
      Panels = <
        item
          Width = 100
        end>
    end
  end
  object db_main: TIBDatabase
    LoginPrompt = False
    Left = 576
    Top = 152
  end
  object ta_main: TIBTransaction
    DefaultDatabase = db_main
    Params.Strings = (
      'read_committed'
      'rec_version'
      'nowait'
      'read')
    Left = 616
    Top = 248
  end
  object ibquery_main: TIBQuery
    Database = db_main
    Transaction = ta_main
    Left = 648
    Top = 152
  end
  object Timer_coords: TTimer
    Enabled = False
    Interval = 10000
    OnTimer = Timer_coordsTimer
    Left = 280
    Top = 8
  end
  object Timer_orders: TTimer
    Enabled = False
    Interval = 10000
    OnTimer = Timer_ordersTimer
    Left = 408
    Top = 8
  end
  object Timer_get_time_order: TTimer
    Enabled = False
    OnTimer = Timer_get_time_orderTimer
    Left = 232
    Top = 8
  end
end
