object FormOrder: TFormOrder
  Left = 0
  Top = 0
  Caption = 'FormOrder'
  ClientHeight = 473
  ClientWidth = 743
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
    Width = 743
    Height = 473
    Align = alClient
    Caption = 'GridPanel_main'
    ColumnCollection = <
      item
        Value = 33.333333333333330000
      end
      item
        Value = 66.666666666666660000
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
    ExplicitLeft = 253
    ExplicitTop = 200
    ExplicitWidth = 482
    ExplicitHeight = 265
    object GridPanel_order: TGridPanel
      Left = 1
      Top = 1
      Width = 246
      Height = 471
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
          Value = 80.000000000000000000
        end
        item
          Value = 100.000000000000000000
        end>
      TabOrder = 0
      ExplicitLeft = 0
      ExplicitWidth = 144
      ExplicitHeight = 263
      object GroupBox_controls: TGroupBox
        Left = 1
        Top = 1
        Width = 244
        Height = 80
        Align = alClient
        Caption = 'GroupBox_controls'
        TabOrder = 0
        ExplicitLeft = 2
        ExplicitTop = 0
        ExplicitHeight = 88
        object Button_get_crew: TButton
          Left = 16
          Top = 19
          Width = 137
          Height = 25
          Caption = #1055#1086#1076#1086#1073#1088#1072#1090#1100' '#1101#1082#1080#1087#1072#1078
          TabOrder = 0
        end
        object Button_show_on_map: TButton
          Left = 16
          Top = 50
          Width = 137
          Height = 25
          Caption = #1055#1086#1082#1072#1079#1072#1090#1100' '#1085#1072' '#1082#1072#1088#1090#1077
          TabOrder = 1
        end
      end
      object GroupBox_order: TGroupBox
        Left = 1
        Top = 81
        Width = 244
        Height = 389
        Align = alClient
        Caption = 'GroupBox_order'
        TabOrder = 1
        ExplicitLeft = 2
        ExplicitTop = 15
        ExplicitWidth = 240
        ExplicitHeight = 63
        object grid_order: TStringGrid
          Left = 2
          Top = 15
          Width = 240
          Height = 372
          Align = alClient
          ColCount = 2
          DefaultRowHeight = 16
          FixedCols = 0
          TabOrder = 0
          ExplicitLeft = 24
          ExplicitTop = 41
          ExplicitWidth = 145
          ExplicitHeight = 120
        end
      end
    end
    object GridPanel_crews_browser: TGridPanel
      Left = 247
      Top = 1
      Width = 495
      Height = 471
      Align = alClient
      Caption = 'GridPanel_crews_browser'
      ColumnCollection = <
        item
          Value = 50.000000000000000000
        end
        item
          Value = 50.000000000000000000
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
      ExplicitLeft = 336
      ExplicitTop = 96
      ExplicitWidth = 185
      ExplicitHeight = 41
      object GroupBox_crews: TGroupBox
        Left = 1
        Top = 1
        Width = 246
        Height = 469
        Align = alClient
        Caption = #1055#1086#1076#1073#1086#1088' '#1101#1082#1080#1087#1072#1078#1072' '#1076#1083#1103' '#1079#1072#1082#1072#1079#1072
        TabOrder = 0
        ExplicitTop = 51
        ExplicitHeight = 189
        object grid_crews: TStringGrid
          Left = 2
          Top = 15
          Width = 242
          Height = 452
          Align = alClient
          DefaultRowHeight = 16
          FixedCols = 0
          TabOrder = 0
          ExplicitLeft = 1
          ExplicitTop = 17
          ExplicitWidth = 159
          ExplicitHeight = 172
        end
      end
      object GroupBox1: TGroupBox
        Left = 247
        Top = 1
        Width = 247
        Height = 469
        Align = alClient
        Caption = #1052#1072#1088#1096#1088#1091#1090' '#1085#1072' '#1082#1072#1088#1090#1077':'
        TabOrder = 1
        ExplicitLeft = 1
        ExplicitTop = 240
        ExplicitWidth = 246
        ExplicitHeight = 191
        object WebBrowser1: TWebBrowser
          Left = 2
          Top = 15
          Width = 243
          Height = 452
          Align = alClient
          TabOrder = 0
          ExplicitLeft = 86
          ExplicitTop = 21
          ExplicitWidth = 160
          ExplicitHeight = 150
          ControlData = {
            4C0000001D190000B72E00000000000000000000000000000000000000000000
            000000004C000000000000000000000001000000E0D057007335CF11AE690800
            2B2E126208000000000000004C0000000114020000000000C000000000000046
            8000000000000000000000000000000000000000000000000000000000000000
            00000000000000000100000000000000000000000000000000000000}
        end
      end
    end
  end
end
