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
          SizeStyle = ssAbsolute
          Value = 200.000000000000000000
        end
        item
          Value = 100.000000000000000000
        end>
      TabOrder = 0
      object GroupBox_crew: TGroupBox
        Left = 1
        Top = 1
        Width = 333
        Height = 200
        Align = alClient
        Caption = 'GroupBox_crew'
        TabOrder = 0
        ExplicitHeight = 160
        object grid_crew: TStringGrid
          AlignWithMargins = True
          Left = 5
          Top = 18
          Width = 323
          Height = 177
          Align = alClient
          ColCount = 4
          Ctl3D = False
          DefaultRowHeight = 16
          FixedCols = 0
          RowCount = 1
          FixedRows = 0
          ParentCtl3D = False
          TabOrder = 0
          ExplicitHeight = 137
        end
      end
      object GroupBox_coords: TGroupBox
        Left = 1
        Top = 201
        Width = 333
        Height = 183
        Align = alClient
        Caption = 'GPS-'#1090#1088#1077#1082' '#1101#1082#1080#1087#1072#1078#1072':'
        TabOrder = 1
        ExplicitTop = 161
        ExplicitHeight = 223
        object grid_coords: TStringGrid
          AlignWithMargins = True
          Left = 5
          Top = 18
          Width = 323
          Height = 160
          Align = alClient
          ColCount = 4
          Ctl3D = False
          DefaultRowHeight = 16
          FixedCols = 0
          RowCount = 1
          FixedRows = 0
          ParentCtl3D = False
          TabOrder = 0
          OnDblClick = grid_coordsDblClick
          ExplicitHeight = 200
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
      object GroupBox_ctrls: TGroupBox
        Left = 1
        Top = 1
        Width = 333
        Height = 50
        Align = alClient
        Caption = #1044#1077#1081#1089#1090#1074#1080#1103':'
        TabOrder = 0
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
        Caption = #1050#1072#1088#1090#1072':'
        TabOrder = 1
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
