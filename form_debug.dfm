object FormDebug: TFormDebug
  Left = 0
  Top = 0
  Caption = 'FormDebug'
  ClientHeight = 218
  ClientWidth = 426
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  OnCloseQuery = FormCloseQuery
  PixelsPerInch = 96
  TextHeight = 13
  object GridPanel1: TGridPanel
    Left = 0
    Top = 0
    Width = 426
    Height = 218
    Align = alClient
    Caption = 'GridPanel1'
    ColumnCollection = <
      item
        Value = 100.000000000000000000
      end>
    ControlCollection = <
      item
        Column = 0
        Control = sg_orders
        Row = 0
      end
      item
        Column = 0
        Control = sg_crews
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
    object sg_orders: TStringGrid
      AlignWithMargins = True
      Left = 4
      Top = 4
      Width = 418
      Height = 102
      Align = alClient
      ColCount = 4
      Ctl3D = False
      DefaultRowHeight = 16
      FixedCols = 0
      RowCount = 1
      FixedRows = 0
      ParentCtl3D = False
      TabOrder = 0
    end
    object sg_crews: TStringGrid
      AlignWithMargins = True
      Left = 4
      Top = 112
      Width = 418
      Height = 102
      Align = alClient
      ColCount = 4
      Ctl3D = False
      DefaultRowHeight = 16
      FixedCols = 0
      RowCount = 1
      FixedRows = 0
      ParentCtl3D = False
      TabOrder = 1
    end
  end
end
