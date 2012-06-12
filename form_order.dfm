object FormOrder: TFormOrder
  Left = 0
  Top = 0
  Caption = 'FormOrder'
  ClientHeight = 294
  ClientWidth = 795
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
    Width = 795
    Height = 294
    Align = alClient
    Caption = 'GridPanel_main'
    ColumnCollection = <
      item
        SizeStyle = ssAbsolute
        Value = 200.000000000000000000
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
      Width = 200
      Height = 292
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
        Width = 198
        Height = 120
        Align = alClient
        Caption = 'GroupBox_controls'
        TabOrder = 0
        object Button_get_crew: TButton
          Left = 3
          Top = 15
          Width = 118
          Height = 25
          Caption = #1055#1086#1076#1086#1073#1088#1072#1090#1100' '#1101#1082#1080#1087#1072#1078
          TabOrder = 0
          OnClick = Button_get_crewClick
        end
        object Button_show_on_map: TButton
          Left = 6
          Top = 70
          Width = 118
          Height = 25
          Caption = #1055#1086#1082#1072#1079#1072#1090#1100' '#1085#1072' '#1082#1072#1088#1090#1077
          TabOrder = 1
        end
        object Edit_gps: TEdit
          Left = 5
          Top = 43
          Width = 118
          Height = 21
          TabOrder = 2
        end
      end
      object GroupBox_order: TGroupBox
        Left = 1
        Top = 121
        Width = 198
        Height = 170
        Align = alClient
        Caption = 'GroupBox_order'
        TabOrder = 1
        object grid_order: TStringGrid
          Left = 2
          Top = 15
          Width = 194
          Height = 153
          Align = alClient
          ColCount = 2
          DefaultRowHeight = 16
          FixedCols = 0
          TabOrder = 0
        end
      end
    end
    object GridPanel_crews_browser: TGridPanel
      Left = 201
      Top = 1
      Width = 593
      Height = 292
      Align = alClient
      Caption = 'GridPanel_crews_browser'
      ColumnCollection = <
        item
          Value = 100.000000000000000000
        end
        item
          SizeStyle = ssAbsolute
          Value = 120.000000000000000000
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
        Width = 471
        Height = 290
        Align = alClient
        Caption = #1055#1086#1076#1073#1086#1088' '#1101#1082#1080#1087#1072#1078#1072' '#1076#1083#1103' '#1079#1072#1082#1072#1079#1072
        TabOrder = 0
        object grid_crews: TStringGrid
          Left = 2
          Top = 15
          Width = 467
          Height = 273
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
      object GroupBox1: TGroupBox
        Left = 472
        Top = 1
        Width = 120
        Height = 290
        Align = alClient
        Caption = #1052#1072#1088#1096#1088#1091#1090' '#1085#1072' '#1082#1072#1088#1090#1077':'
        TabOrder = 1
        object WebBrowser1: TWebBrowser
          Left = 2
          Top = 15
          Width = 116
          Height = 273
          Align = alClient
          TabOrder = 0
          ExplicitLeft = 86
          ExplicitTop = 21
          ExplicitWidth = 160
          ExplicitHeight = 150
          ControlData = {
            4C000000FD0B0000371C00000000000000000000000000000000000000000000
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
    Left = 208
    Top = 120
  end
  object Timer_get_crews: TTimer
    Enabled = False
    Interval = 512
    OnTimer = Timer_get_crewsTimer
    Left = 304
    Top = 120
  end
  object Timer_show_crews: TTimer
    Enabled = False
    Interval = 1011
    OnTimer = Timer_show_crewsTimer
    Left = 408
    Top = 120
  end
end
