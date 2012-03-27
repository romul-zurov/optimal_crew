object FormOrder: TFormOrder
  Left = 0
  Top = 0
  Caption = 'FormOrder'
  ClientHeight = 365
  ClientWidth = 695
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
  object GroupBox_crews: TGroupBox
    Left = 0
    Top = 0
    Width = 695
    Height = 365
    Align = alClient
    Caption = #1055#1086#1076#1073#1086#1088' '#1101#1082#1080#1087#1072#1078#1072' '#1076#1083#1103' '#1079#1072#1082#1072#1079#1072
    TabOrder = 0
    ExplicitLeft = 376
    ExplicitTop = 152
    ExplicitWidth = 185
    ExplicitHeight = 105
    object grid_crews: TStringGrid
      Left = 2
      Top = 15
      Width = 691
      Height = 348
      Align = alClient
      DefaultRowHeight = 16
      FixedCols = 0
      TabOrder = 0
      ExplicitLeft = 296
      ExplicitTop = 128
      ExplicitWidth = 320
      ExplicitHeight = 120
    end
  end
end
