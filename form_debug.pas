unit form_debug;

interface

uses
	Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
	Dialogs, Grids, ExtCtrls;

type
	TFormDebug = class(TForm)
		GridPanel1 : TGridPanel;
		sg_orders : TStringGrid;
		sg_crews : TStringGrid;
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
	private
		{ Private declarations }
		procedure show_grid(var list : TSTringList; var grid : TStringGrid);
	public
		{ Public declarations }
		procedure show_orders(var list : TSTringList);
		procedure show_crews(var list : TSTringList);
	end;

var
	FormDebug : TFormDebug;

implementation

{$R *.dfm}
{ TFormDebug }

procedure TFormDebug.FormCloseQuery(Sender: TObject; var CanClose: Boolean);
begin
	self.Hide();
end;

procedure TFormDebug.show_crews(var list : TSTringList);
begin
	self.show_grid(list, self.sg_crews);
end;

procedure TFormDebug.show_grid(var list : TSTringList; var grid : TStringGrid);
begin
	grid.ColCount := 1; grid.RowCount := list.Count; grid.ColWidths[0] := grid.Width;
	grid.Cols[0].Assign(list);
end;

procedure TFormDebug.show_orders(var list : TSTringList);
begin
	self.show_grid(list, self.sg_orders);
end;

end.
