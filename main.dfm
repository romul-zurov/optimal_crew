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
      Height = 28
      Margins.Left = 4
      Margins.Top = 4
      Margins.Right = 4
      Margins.Bottom = 4
      Align = alTop
      AutoSize = True
      TabOrder = 0
      DesignSize = (
        754
        28)
      object Button1: TButton
        Left = 609
        Top = 2
        Width = 144
        Height = 25
        Anchors = [akTop, akRight]
        Caption = #1058#1072#1081#1084#1077#1088' '#1074#1088#1077#1084#1103' '#1076#1086' '#1072#1087' '#1086#1090#1082#1083'!'
        TabOrder = 0
        OnClick = Button1Click
      end
      object cb_real_base: TCheckBox
        Left = 582
        Top = 5
        Width = 30
        Height = 17
        Anchors = [akTop, akRight]
        Caption = 'R'
        TabOrder = 1
        OnClick = cb_real_baseClick
      end
      object button_show_sl: TButton
        Left = 69
        Top = 1
        Width = 75
        Height = 25
        Anchors = [akTop, akRight]
        Caption = 'Debug'
        TabOrder = 2
        OnClick = button_show_slClick
      end
      object Button_show_order: TButton
        Left = 462
        Top = 2
        Width = 114
        Height = 25
        Anchors = [akTop, akRight]
        Caption = #1055#1086#1076#1088#1086#1073#1085#1086#1089#1090#1080' '#1079#1072#1082#1072#1079#1072
        TabOrder = 3
        OnClick = Button_show_orderClick
      end
      object cb_show_crews: TCheckBox
        Left = 391
        Top = 4
        Width = 65
        Height = 17
        Anchors = [akTop, akRight]
        Caption = #1069#1082#1080#1087#1072#1078#1080
        TabOrder = 4
        OnClick = cb_show_crewsClick
      end
      object Panel_browser: TPanel
        Left = 6
        Top = 5
        Width = 17
        Height = 17
        TabOrder = 5
      end
      object Button_get_time_to_ap: TButton
        Left = 269
        Top = 2
        Width = 108
        Height = 24
        Caption = #1074#1088#1077#1084#1103' '#1076#1086' '#1087#1086#1076#1072#1095#1080
        TabOrder = 6
        OnClick = Button_get_time_to_apClick
      end
      object Button_get_time_to_end: TButton
        Left = 150
        Top = 2
        Width = 113
        Height = 24
        Caption = #1074#1088#1077#1084#1103' '#1076#1086' '#1086#1082#1086#1085#1095#1072#1085#1080#1103
        TabOrder = 7
        OnClick = Button_get_time_to_endClick
      end
    end
    object GridPanel_grids: TGridPanel
      Left = 1
      Top = 37
      Width = 762
      Height = 318
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
        Height = 316
        Align = alClient
        Caption = #1047#1072#1082#1072#1079#1099':'
        TabOrder = 0
        object PageControl_orders: TPageControl
          Left = 2
          Top = 15
          Width = 506
          Height = 299
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
              Height = 265
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
              Height = 265
              Align = alClient
              ColCount = 3
              Ctl3D = False
              DefaultRowHeight = 16
              FixedCols = 0
              RowCount = 1
              FixedRows = 0
              ParentCtl3D = False
              TabOrder = 0
              OnDblClick = grid_order_priorDblClick
            end
          end
        end
      end
      object GroupBox_crew: TGroupBox
        Left = 511
        Top = 1
        Width = 250
        Height = 316
        Align = alClient
        Caption = #1044#1086#1089#1090#1091#1087#1085#1099#1077' '#1101#1082#1080#1087#1072#1078#1080':'
        TabOrder = 1
        object grid_crews: TStringGrid
          AlignWithMargins = True
          Left = 5
          Top = 18
          Width = 240
          Height = 293
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
    Left = 120
    Top = 160
  end
  object Timer_orders: TTimer
    Enabled = False
    Interval = 10000
    OnTimer = Timer_ordersTimer
    Left = 176
    Top = 192
  end
  object Timer_get_time_order: TTimer
    Enabled = False
    Interval = 1127
    OnTimer = Timer_get_time_orderTimer
    Left = 56
    Top = 192
  end
  object Timer_show_order_grid: TTimer
    Enabled = False
    Interval = 2048
    OnTimer = Timer_show_order_gridTimer
    Left = 224
    Top = 144
  end
  object Timer_get_time_order_to_ap: TTimer
    Enabled = False
    Interval = 31000
    OnTimer = Timer_get_time_order_to_apTimer
    Left = 88
    Top = 248
  end
end
