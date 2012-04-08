object FormCrew: TFormCrew
  Left = 0
  Top = 0
  Caption = 'FormCrew'
  ClientHeight = 387
  ClientWidth = 672
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  OnClose = FormClose
  OnCreate = FormCreate
  OnResize = FormResize
  PixelsPerInch = 96
  TextHeight = 13
  object GridPanel_main: TGridPanel
    Left = 0
    Top = 0
    Width = 672
    Height = 387
    Align = alClient
    Caption = 'GridPanel_main'
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
        Control = GridPanel_grids
        Row = 0
      end
      item
        Column = 1
        Control = GridPanel_ctrls
        Row = 0
      end>
    RowCollection = <
      item
        Value = 100.000000000000000000
      end>
    TabOrder = 0
    ExplicitLeft = 120
    ExplicitTop = 176
    ExplicitWidth = 185
    ExplicitHeight = 41
    object GridPanel_grids: TGridPanel
      Left = 1
      Top = 1
      Width = 335
      Height = 385
      Align = alClient
      Caption = 'GridPanel_grids'
      ColumnCollection = <
        item
          Value = 100.000000000000000000
        end>
      ControlCollection = <
        item
          Column = 0
          Control = GroupBox_crew
          Row = 0
        end
        item
          Column = 0
          Control = GroupBox_coords
          Row = 1
        end>
      RowCollection = <
        item
          Value = 50.000000000000000000
        end
        item
          Value = 50.000000000000000000
        end>
      TabOrder = 0
      ExplicitLeft = 272
      ExplicitTop = 152
      ExplicitWidth = 185
      ExplicitHeight = 41
      object GroupBox_crew: TGroupBox
        Left = 1
        Top = 1
        Width = 333
        Height = 191
        Align = alClient
        Caption = 'GroupBox_crew'
        TabOrder = 0
        ExplicitLeft = 208
        ExplicitTop = 112
        ExplicitWidth = 185
        ExplicitHeight = 105
        object grid_crew: TStringGrid
          AlignWithMargins = True
          Left = 5
          Top = 18
          Width = 323
          Height = 168
          Align = alClient
          ColCount = 4
          Ctl3D = False
          DefaultRowHeight = 16
          FixedCols = 0
          RowCount = 1
          FixedRows = 0
          ParentCtl3D = False
          TabOrder = 0
          ExplicitWidth = 252
          ExplicitHeight = 301
        end
      end
      object GroupBox_coords: TGroupBox
        Left = 1
        Top = 192
        Width = 333
        Height = 192
        Align = alClient
        Caption = 'GroupBox_coords'
        TabOrder = 1
        ExplicitLeft = 160
        ExplicitTop = 312
        ExplicitWidth = 185
        ExplicitHeight = 105
        object grid_coords: TStringGrid
          AlignWithMargins = True
          Left = 5
          Top = 18
          Width = 323
          Height = 169
          Align = alClient
          ColCount = 4
          Ctl3D = False
          DefaultRowHeight = 16
          FixedCols = 0
          RowCount = 1
          FixedRows = 0
          ParentCtl3D = False
          TabOrder = 0
          ExplicitWidth = 252
          ExplicitHeight = 301
        end
      end
    end
    object GridPanel_ctrls: TGridPanel
      Left = 336
      Top = 1
      Width = 335
      Height = 385
      Align = alClient
      Caption = 'GridPanel_ctrls'
      ColumnCollection = <
        item
          Value = 100.000000000000000000
        end>
      ControlCollection = <
        item
          Column = 0
          Control = GroupBox_ctrls
          Row = 0
        end
        item
          Column = 0
          Control = GroupBox_browser
          Row = 1
        end>
      RowCollection = <
        item
          SizeStyle = ssAbsolute
          Value = 50.000000000000000000
        end
        item
          Value = 100.000000000000000000
        end>
      TabOrder = 1
      ExplicitLeft = 512
      ExplicitTop = 216
      ExplicitWidth = 185
      ExplicitHeight = 41
      object GroupBox_ctrls: TGroupBox
        Left = 1
        Top = 1
        Width = 333
        Height = 50
        Align = alClient
        Caption = 'GroupBox_ctrls'
        TabOrder = 0
        ExplicitLeft = 40
        ExplicitTop = 16
        ExplicitWidth = 254
        ExplicitHeight = 133
        DesignSize = (
          333
          50)
        object Button_reload: TButton
          Left = 248
          Top = 16
          Width = 75
          Height = 25
          Anchors = [akTop, akRight]
          Caption = #1054#1073#1085#1086#1074#1080#1090#1100
          TabOrder = 0
        end
        object Button_show_on_map: TButton
          Left = 96
          Top = 16
          Width = 146
          Height = 25
          Anchors = [akTop, akRight]
          Caption = #1055#1086#1082#1072#1079#1072#1090#1100' '#1085#1072' '#1082#1072#1088#1090#1077
          TabOrder = 1
        end
      end
      object GroupBox_browser: TGroupBox
        Left = 1
        Top = 51
        Width = 333
        Height = 333
        Align = alClient
        Caption = 'GroupBox_browser'
        TabOrder = 1
        ExplicitLeft = 120
        ExplicitTop = 288
        ExplicitWidth = 185
        ExplicitHeight = 105
        object browser: TWebBrowser
          Left = 2
          Top = 15
          Width = 329
          Height = 316
          Align = alClient
          TabOrder = 0
          ExplicitLeft = 120
          ExplicitTop = 152
          ExplicitWidth = 300
          ExplicitHeight = 150
          ControlData = {
            4C00000001220000A92000000000000000000000000000000000000000000000
            000000004C000000000000000000000001000000E0D057007335CF11AE690800
            2B2E126208000000000000004C0000000114020000000000C000000000000046
            8000000000000000000000000000000000000000000000000000000000000000
            00000000000000000100000000000000000000000000000000000000}
        end
      end
    end
  end
end
