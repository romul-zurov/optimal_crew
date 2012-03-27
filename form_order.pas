unit form_order;

interface

uses
	crew_utils, //
	Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
	Dialogs, Grids, StdCtrls;

type
	TFormOrder = class(TForm)
		GroupBox_crews : TGroupBox;
		grid_crews : TStringGrid;
		procedure FormCreate(Sender : TObject);
		procedure FormClose(Sender : TObject; var Action : TCloseAction);
	private
		{ Private declarations }
	public
		{ Public declarations }
		procedure show_crews(var slist : tstringlist);
	end;

var
	FormOrder : TFormOrder;

implementation

{$R *.dfm}

procedure TFormOrder.FormClose(Sender : TObject; var Action : TCloseAction);
begin
	self.Hide();
end;

procedure TFormOrder.FormCreate(Sender : TObject);
begin
	self.Width := 800;
	self.Height := 400;
end;

procedure TFormOrder.show_crews(var slist : tstringlist);
var s : string;
	r : integer;
begin
	with self.grid_crews do
	begin
		RowCount := 2;
		ColCount := 5;
		FixedRows := 1;
		ColWidths[0] := 50;
		// ColWidths[1] := 200;
		ColWidths[2] := 120;
		ColWidths[3] := 100;
		ColWidths[4] := 120; // (Width - ColWidths[0] - ColWidths[1] - ColWidths[2] - ColWidths[3] - 20) div 2;
		ColWidths[1] := Width - 24 - ColWidths[0] - ColWidths[2] //
			- ColWidths[3] - ColWidths[4];

		Cells[0, 0] := '№';
		Cells[1, 0] := 'Экипаж';
		Cells[2, 0] := 'Состояние';
		Cells[3, 0] := 'Время подачи';
		Cells[4, 0] := 'Расстояние';
	end;

	r := 1;
	for s in slist do
		with self.grid_crews do
		begin
			RowCount := r + 1;
			Cells[0, r] := get_substr(s, '', '|');
			Cells[1, r] := get_substr(s, '|', '||');
			Cells[2, r] := get_substr(s, '||', '|||');
			Cells[3, r] := get_substr(s, '|||', '||||');
			Cells[4, r] := get_substr(s, '||||', '') + 'км';
			inc(r);
		end;
end;

end.
