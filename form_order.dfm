object FormOrder: TFormOrder
  Left = 0
  Top = 0
  Caption = 'FormOrder'
  ClientHeight = 416
  ClientWidth = 885
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
    Left = 0
    Top = 0
    Width = 885
    Height = 416
    Align = alClient
    Caption = 'GridPanel_main'
    ColumnCollection = <
      item
        SizeStyle = ssAbsolute
        Value = 600.000000000000000000
      end
      item
        Value = 100.000000000000000000
      end>
    ControlCollection = <
      item
        Column = 0
        Control = GridPanel_order
        Row = 0
      end
      item
        Column = 1
        Control = GridPanel_crews_browser
        Row = 0
      end>
    RowCollection = <
      item
        Value = 100.000000000000000000
      end>
    TabOrder = 0
    object GridPanel_order: TGridPanel
      Left = 1
      Top = 1
      Width = 600
      Height = 414
      Align = alClient
      Caption = 'GridPanel_order'
      ColumnCollection = <
        item
          Value = 100.000000000000000000
        end>
      ControlCollection = <
        item
          Column = 0
          Control = GroupBox_controls
          Row = 0
        end
        item
          Column = 0
          Control = GroupBox_order
          Row = 1
        end>
      RowCollection = <
        item
          SizeStyle = ssAbsolute
          Value = 120.000000000000000000
        end
        item
          Value = 100.000000000000000000
        end>
      TabOrder = 0
      object GroupBox_controls: TGroupBox
        Left = 1
        Top = 1
        Width = 598
        Height = 120
        Align = alClient
        Caption = 'GroupBox_controls'
        TabOrder = 0
        object Button_get_crew: TButton
          Left = 3
          Top = 15
          Width = 190
          Height = 25
          Caption = #1055#1086#1076#1086#1073#1088#1072#1090#1100' '#1101#1082#1080#1087#1072#1078
          TabOrder = 0
          OnClick = Button_get_crewClick
        end
        object Button_get_cars: TButton
          Left = 6
          Top = 70
          Width = 187
          Height = 25
          Caption = #1072#1074#1090#1086#1087#1086#1076#1073#1086#1088'*'
          TabOrder = 1
          OnClick = Button_get_carsClick
        end
        object Edit_gps: TEdit
          Left = 5
          Top = 43
          Width = 188
          Height = 21
          TabOrder = 2
        end
        object cb_debug: TCheckBox
          Left = 6
          Top = 100
          Width = 67
          Height = 17
          Caption = #1086#1090#1083#1072#1076#1082#1072
          TabOrder = 3
          OnClick = cb_debugClick
        end
      end
      object GroupBox_order: TGroupBox
        Left = 1
        Top = 121
        Width = 598
        Height = 292
        Align = alClient
        Caption = 'GroupBox_order'
        TabOrder = 1
        object grid_order: TStringGrid
          Left = 2
          Top = 15
          Width = 594
          Height = 275
          Align = alClient
          ColCount = 2
          DefaultRowHeight = 16
          FixedCols = 0
          TabOrder = 0
          OnDblClick = grid_orderDblClick
        end
      end
    end
    object GridPanel_crews_browser: TGridPanel
      Left = 601
      Top = 1
      Width = 283
      Height = 414
      Align = alClient
      Caption = 'GridPanel_crews_browser'
      ColumnCollection = <
        item
          Value = 100.000000000000000000
        end
        item
          SizeStyle = ssAbsolute
          Value = 8.000000000000000000
        end>
      ControlCollection = <
        item
          Column = 0
          Control = GroupBox_crews
          Row = 0
        end
        item
          Column = 1
          Control = GroupBox1
          Row = 0
        end>
      RowCollection = <
        item
          Value = 100.000000000000000000
        end>
      TabOrder = 1
      object GroupBox_crews: TGroupBox
        Left = 1
        Top = 1
        Width = 273
        Height = 412
        Align = alClient
        Caption = #1055#1086#1076#1073#1086#1088' '#1101#1082#1080#1087#1072#1078#1072' '#1076#1083#1103' '#1079#1072#1082#1072#1079#1072
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clWindowText
        Font.Height = -11
        Font.Name = 'Tahoma'
        Font.Style = [fsBold]
        ParentFont = False
        TabOrder = 0
        object stbar_crews: TStatusBar
          Left = 2
          Top = 391
          Width = 269
          Height = 19
          Panels = <
            item
              Width = 50
            end
            item
              Width = 50
            end>
        end
        object PageControl_cars: TPageControl
          Left = 2
          Top = 15
          Width = 269
          Height = 376
          ActivePage = TabSheet_current
          Align = alClient
          TabOrder = 1
          object TabSheet_current: TTabSheet
            Caption = #1072#1074#1090#1086#1087#1086#1076#1073#1086#1088
            object grid_cars: TStringGrid
              Left = 0
              Top = 0
              Width = 261
              Height = 348
              Align = alClient
              DefaultRowHeight = 16
              FixedCols = 0
              Font.Charset = DEFAULT_CHARSET
              Font.Color = clWindowText
              Font.Height = -11
              Font.Name = 'Tahoma'
              Font.Style = [fsBold]
              ParentFont = False
              TabOrder = 0
              OnDrawCell = grid_crewsDrawCell
            end
          end
          object TabSheet_prior: TTabSheet
            Caption = #1074#1088#1091#1095#1085#1091#1102
            ImageIndex = 1
            ExplicitLeft = 0
            ExplicitTop = 0
            ExplicitWidth = 0
            ExplicitHeight = 0
            object grid_crews: TStringGrid
              Left = 0
              Top = 0
              Width = 461
              Height = 348
              Align = alClient
              DefaultRowHeight = 16
              FixedCols = 0
              Font.Charset = DEFAULT_CHARSET
              Font.Color = clWindowText
              Font.Height = -11
              Font.Name = 'Tahoma'
              Font.Style = [fsBold]
              ParentFont = False
              TabOrder = 0
              OnDrawCell = grid_crewsDrawCell
            end
          end
        end
      end
      object GroupBox1: TGroupBox
        Left = 274
        Top = 1
        Width = 8
        Height = 412
        Align = alClient
        Caption = #1052#1072#1088#1096#1088#1091#1090' '#1085#1072' '#1082#1072#1088#1090#1077':'
        TabOrder = 1
        object WebBrowser1: TWebBrowser
          Left = 2
          Top = 15
          Width = 4
          Height = 395
          Align = alClient
          TabOrder = 0
          ExplicitLeft = 86
          ExplicitTop = 21
          ExplicitWidth = 160
          ExplicitHeight = 150
          ControlData = {
            4C0000006A000000D32800000000000000000000000000000000000000000000
            000000004C000000000000000000000001000000E0D057007335CF11AE690800
            2B2E126208000000000000004C0000000114020000000000C000000000000046
            8000000000000000000000000000000000000000000000000000000000000000
            00000000000000000100000000000000000000000000000000000000}
        end
      end
    end
  end
  object Timer_get_gps: TTimer
    Enabled = False
    Interval = 512
    OnTimer = Timer_get_gpsTimer
    Left = 32
    Top = 200
  end
  object Timer_get_crews: TTimer
    Enabled = False
    Interval = 100
    OnTimer = Timer_get_crewsTimer
    Left = 112
    Top = 200
  end
  object Timer_show_crews: TTimer
    Enabled = False
    Interval = 1011
    OnTimer = Timer_show_crewsTimer
    Left = 40
    Top = 320
  end
  object Timer_show_cars: TTimer
    Enabled = False
    Interval = 998
    OnTimer = Timer_show_carsTimer
    Left = 120
    Top = 344
  end
  object Timer_get_cars: TTimer
    Enabled = False
    Interval = 5000
    OnTimer = Timer_get_carsTimer
    Left = 80
    Top = 256
  end
end
