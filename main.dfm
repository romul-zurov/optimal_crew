object form_main: Tform_main
  Left = 0
  Top = 0
  Caption = #1055#1086#1076#1073#1086#1088' '#1086#1087#1090#1080#1084#1072#1083#1100#1085#1086#1075#1086' '#1101#1082#1080#1087#1072#1078#1072' '#1040#1057'-'#1058#1072#1082#1089#1080
  ClientHeight = 419
  ClientWidth = 805
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
    Width = 799
    Height = 413
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
        Row = 3
      end
      item
        Column = 0
        Row = 0
      end
      item
        Column = 0
        Control = ScrollBox_cars
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
        SizeStyle = ssAbsolute
        Value = 200.000000000000000000
      end
      item
        SizeStyle = ssAbsolute
        Value = 20.000000000000000000
      end>
    TabOrder = 0
    object panel_ap: TPanel
      AlignWithMargins = True
      Left = 5
      Top = 5
      Width = 789
      Height = 28
      Margins.Left = 4
      Margins.Top = 4
      Margins.Right = 4
      Margins.Bottom = 4
      Align = alTop
      AutoSize = True
      TabOrder = 0
      DesignSize = (
        789
        28)
      object Button_orders_coords: TButton
        Left = 215
        Top = 1
        Width = 98
        Height = 25
        Caption = #1079#1072#1082#1072#1079#1099'/'#1082#1086#1086#1088#1076'-'#1090#1099
        TabOrder = 0
        OnClick = Button_orders_coordsClick
      end
      object cb_real_base: TCheckBox
        Left = 753
        Top = 5
        Width = 27
        Height = 17
        Anchors = [akTop, akRight]
        Caption = 'R'
        Checked = True
        State = cbChecked
        TabOrder = 1
        OnClick = cb_real_baseClick
      end
      object button_show_sl: TButton
        Left = 29
        Top = 2
        Width = 36
        Height = 25
        Caption = 'Debug'
        TabOrder = 2
        OnClick = button_show_slClick
      end
      object Button_show_order: TButton
        Left = 319
        Top = 1
        Width = 20
        Height = 25
        Caption = '_'
        TabOrder = 3
        OnClick = Button_show_orderClick
      end
      object cb_show_crews: TCheckBox
        Left = 547
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
        Left = 151
        Top = 2
        Width = 58
        Height = 24
        Caption = #1076#1086' '#1087#1086#1076#1072#1095#1080
        TabOrder = 6
        OnClick = Button_get_time_to_apClick
      end
      object Button_get_time_to_end: TButton
        Left = 71
        Top = 2
        Width = 74
        Height = 24
        Caption = #1076#1086' '#1086#1082#1086#1085#1095#1072#1085#1080#1103
        TabOrder = 7
        OnClick = Button_get_time_to_endClick
      end
      object cb_timers_times: TCheckBox
        Left = 618
        Top = 4
        Width = 65
        Height = 17
        Anchors = [akTop, akRight]
        Caption = #1074#1088#1077#1084#1077#1085#1072
        Checked = True
        State = cbChecked
        TabOrder = 8
        OnClick = cb_timers_timesClick
      end
      object cb_timers_orders_coords: TCheckBox
        Left = 689
        Top = 4
        Width = 58
        Height = 17
        Anchors = [akTop, akRight]
        Caption = #1079#1072#1082#1072#1079#1099
        Checked = True
        State = cbChecked
        TabOrder = 9
        OnClick = cb_timers_orders_coordsClick
      end
      object cb_show_times_to_end: TCheckBox
        Left = 448
        Top = 4
        Width = 93
        Height = 17
        Anchors = [akTop, akRight]
        Caption = #1044#1086' '#1086#1082#1086#1085#1095#1072#1085#1080#1103
        TabOrder = 10
        OnClick = cb_show_crewsClick
      end
      object cb_show_orders_id: TCheckBox
        Left = 381
        Top = 4
        Width = 68
        Height = 17
        Anchors = [akTop, akRight]
        Caption = 'OrdersID'
        TabOrder = 11
        OnClick = cb_show_crewsClick
      end
    end
    object GridPanel_grids: TGridPanel
      Left = 1
      Top = 37
      Width = 797
      Height = 155
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
        Width = 545
        Height = 153
        Align = alClient
        Caption = #1047#1072#1082#1072#1079#1099':'
        TabOrder = 0
        OnDblClick = GroupBox_orderDblClick
        object PageControl_orders: TPageControl
          Left = 2
          Top = 15
          Width = 541
          Height = 136
          ActivePage = TabSheet_current
          Align = alClient
          TabOrder = 0
          object TabSheet_current: TTabSheet
            Caption = #1058#1077#1082#1091#1097#1080#1077':'
            object grid_order_current: TStringGrid
              AlignWithMargins = True
              Left = 3
              Top = 3
              Width = 527
              Height = 102
              Align = alClient
              ColCount = 3
              Ctl3D = False
              DefaultRowHeight = 16
              FixedCols = 0
              RowCount = 1
              FixedRows = 0
              Font.Charset = DEFAULT_CHARSET
              Font.Color = clWindowText
              Font.Height = -11
              Font.Name = 'Tahoma'
              Font.Style = [fsBold]
              ParentCtl3D = False
              ParentFont = False
              TabOrder = 0
              OnDblClick = grid_order_currentDblClick
              OnDrawCell = grid_order_currentDrawCell
              OnMouseDown = grid_order_currentMouseDown
            end
          end
          object TabSheet_prior: TTabSheet
            Caption = #1055#1088#1077#1076#1074#1072#1088#1080#1090#1077#1083#1100#1085#1099#1077
            ImageIndex = 1
            object grid_order_prior: TStringGrid
              AlignWithMargins = True
              Left = 3
              Top = 3
              Width = 527
              Height = 102
              Align = alClient
              ColCount = 3
              Ctl3D = False
              DefaultRowHeight = 16
              FixedCols = 0
              RowCount = 1
              FixedRows = 0
              Font.Charset = DEFAULT_CHARSET
              Font.Color = clWindowText
              Font.Height = -11
              Font.Name = 'Tahoma'
              Font.Style = [fsBold]
              ParentCtl3D = False
              ParentFont = False
              TabOrder = 0
              OnDblClick = grid_order_priorDblClick
              OnMouseDown = grid_order_currentMouseDown
            end
          end
        end
      end
      object GroupBox_crew: TGroupBox
        Left = 546
        Top = 1
        Width = 250
        Height = 153
        Align = alClient
        Caption = #1044#1086#1089#1090#1091#1087#1085#1099#1077' '#1101#1082#1080#1087#1072#1078#1080':'
        TabOrder = 1
        object grid_crews: TStringGrid
          AlignWithMargins = True
          Left = 5
          Top = 18
          Width = 240
          Height = 130
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
      Top = 392
      Width = 797
      Height = 20
      Align = alClient
      Panels = <
        item
          Width = 100
        end
        item
          Width = 100
        end
        item
          Width = 200
        end
        item
          Width = 100
        end
        item
          Width = 100
        end
        item
          Width = 50
        end>
    end
    object ScrollBox_cars: TScrollBox
      Left = 1
      Top = 192
      Width = 797
      Height = 200
      Align = alClient
      TabOrder = 3
    end
  end
  object db_main: TIBDatabase
    LoginPrompt = False
    Left = 680
    Top = 48
  end
  object ta_main: TIBTransaction
    DefaultDatabase = db_main
    Params.Strings = (
      'read_committed'
      'rec_version'
      'nowait'
      'read')
    Left = 632
    Top = 72
  end
  object ibquery_main: TIBQuery
    Database = db_main
    Transaction = ta_main
    Left = 624
    Top = 128
  end
  object Timer_coords: TTimer
    Enabled = False
    Interval = 60000
    OnTimer = Timer_coordsTimer
    Left = 144
    Top = 96
  end
  object Timer_orders: TTimer
    Enabled = False
    Interval = 10000
    OnTimer = Timer_ordersTimer
    Left = 32
    Top = 104
  end
  object Timer_get_time_order: TTimer
    Enabled = False
    Interval = 128
    OnTimer = Timer_get_time_orderTimer
    Left = 88
    Top = 112
  end
  object Timer_show_order_grid: TTimer
    Enabled = False
    Interval = 2000
    OnTimer = Timer_show_order_gridTimer
    Left = 368
    Top = 48
  end
  object ibquery_coords: TIBQuery
    Database = db_main
    Transaction = ta_coords
    Left = 728
    Top = 128
  end
  object ta_coords: TIBTransaction
    DefaultDatabase = db_main
    Params.Strings = (
      'read_committed'
      'rec_version'
      'nowait'
      'read')
    Left = 720
    Top = 72
  end
  object Timer_main: TTimer
    Enabled = False
    Interval = 500
    OnTimer = Timer_mainTimer
    Left = 472
    Top = 56
  end
  object Timer_pass: TTimer
    Enabled = False
    Interval = 500
    OnTimer = Timer_passTimer
    Left = 200
    Top = 88
  end
end
