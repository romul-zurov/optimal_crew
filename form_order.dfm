object FormOrder: TFormOrder
  Left = 0
  Top = 0
  Caption = 'FormOrder'
  ClientHeight = 432
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
  object GridPanel_order: TGridPanel
    Left = 0
    Top = 0
    Width = 743
    Height = 432
    Align = alClient
    Caption = 'GridPanel_order'
    ColumnCollection = <
      item
        Value = 100.000000000000000000
      end>
    ControlCollection = <
      item
        Column = 0
        Control = GroupBox_crews
        Row = 1
      end
      item
        Column = 0
        Control = GroupBox_controls
        Row = 0
      end
      item
        Column = 0
        Control = GroupBox1
        Row = 2
      end>
    RowCollection = <
      item
        SizeStyle = ssAbsolute
        Value = 50.000000000000000000
      end
      item
        Value = 49.960967993754880000
      end
      item
        Value = 50.039032006245120000
      end>
    TabOrder = 0
    ExplicitLeft = 32
    ExplicitTop = 16
    ExplicitWidth = 681
    ExplicitHeight = 393
    object GroupBox_crews: TGroupBox
      Left = 1
      Top = 51
      Width = 741
      Height = 189
      Align = alClient
      Caption = #1055#1086#1076#1073#1086#1088' '#1101#1082#1080#1087#1072#1078#1072' '#1076#1083#1103' '#1079#1072#1082#1072#1079#1072
      TabOrder = 0
      ExplicitLeft = 103
      ExplicitTop = 1
      ExplicitWidth = 497
      ExplicitHeight = 187
      object grid_crews: TStringGrid
        Left = 2
        Top = 15
        Width = 737
        Height = 172
        Align = alClient
        DefaultRowHeight = 16
        FixedCols = 0
        TabOrder = 0
        ExplicitWidth = 415
        ExplicitHeight = 107
      end
    end
    object GroupBox_controls: TGroupBox
      Left = 1
      Top = 1
      Width = 741
      Height = 50
      Align = alClient
      Caption = 'GroupBox_controls'
      TabOrder = 1
      ExplicitLeft = 7
      ExplicitWidth = 674
      ExplicitHeight = 97
      object Button_get_crew: TButton
        Left = 16
        Top = 19
        Width = 137
        Height = 25
        Caption = #1055#1086#1076#1086#1073#1088#1072#1090#1100' '#1101#1082#1080#1087#1072#1078
        TabOrder = 0
      end
    end
    object GroupBox1: TGroupBox
      Left = 1
      Top = 240
      Width = 741
      Height = 191
      Align = alClient
      Caption = #1052#1072#1088#1096#1088#1091#1090' '#1085#1072' '#1082#1072#1088#1090#1077':'
      TabOrder = 2
      ExplicitLeft = 448
      ExplicitTop = 336
      ExplicitWidth = 185
      ExplicitHeight = 105
      object WebBrowser1: TWebBrowser
        Left = 2
        Top = 15
        Width = 737
        Height = 174
        Align = alClient
        TabOrder = 0
        ExplicitLeft = 192
        ExplicitTop = 16
        ExplicitWidth = 300
        ExplicitHeight = 150
        ControlData = {
          4C0000002C4C0000FC1100000000000000000000000000000000000000000000
          000000004C000000000000000000000001000000E0D057007335CF11AE690800
          2B2E126208000000000000004C0000000114020000000000C000000000000046
          8000000000000000000000000000000000000000000000000000000000000000
          00000000000000000100000000000000000000000000000000000000}
      end
    end
  end
end
