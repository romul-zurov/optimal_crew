unit form_crew;

interface

uses crew, crew_globals, crew_utils, //
	Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
	Dialogs, StdCtrls, ExtCtrls, OleCtrls, SHDocVw, Grids;

type
	TFormCrew = class(TForm)
		GridPanel_main : TGridPanel;
		GridPanel_grids : TGridPanel;
		GroupBox_crew : TGroupBox;
		GroupBox_coords : TGroupBox;
		GridPanel_ctrls : TGridPanel;
		GroupBox_ctrls : TGroupBox;
		GroupBox_browser : TGroupBox;
		Button_reload : TButton;
		Button_show_on_map : TButton;
		grid_crew : TStringGrid;
		grid_coords : TStringGrid;
		browser : TWebBrowser;
		procedure FormCreate(Sender : TObject);
		procedure FormClose(Sender : TObject; var Action : TCloseAction);
		procedure FormResize(Sender : TObject);
	private
		{ Private declarations }
		Pcrew : Pointer;
	public
		{ Public declarations }
		procedure show_crew(var Pcrew : Pointer); overload;
		procedure show_crew(); overload;
	end;

var
	FormCrew : TFormCrew;

implementation

{$R *.dfm}

procedure TFormCrew.FormClose(Sender : TObject; var Action : TCloseAction);
begin
	self.Hide();
end;

procedure TFormCrew.FormCreate(Sender : TObject);
begin
	self.Width := 800;
	self.Height := 400;
end;

procedure TFormCrew.FormResize(Sender : TObject);
begin
	self.show_crew();
end;

procedure TFormCrew.show_crew;
begin
	self.show_crew(self.Pcrew);
end;

procedure TFormCrew.show_crew(var Pcrew : Pointer);
	procedure add_row(var grid : TStringGrid; s1, s2 : string);
	begin
		with grid do
		begin
			cells[0, rowcount - 1] := s1;
			cells[1, rowcount - 1] := s2;
			rowcount := rowcount + 1;
		end;
	end;

var crew : TCrew;
	i : integer;
begin
	self.Pcrew := Pcrew;
	crew := TCrew(self.Pcrew);
	if crew = nil then
		exit();
	self.Caption := 'Экипаж ' + inttostr(crew.CrewID);
	self.GroupBox_crew.Caption := self.Caption + ' ' + crew.name;
	with self.grid_crew do
	begin
		rowcount := 1;
		rows[0].Clear();
		colcount := 2;
		ColWidths[0] := 120;
		ColWidths[1] := Width - ColWidths[0] - 20;
	end;
	add_row(self.grid_crew, 'ID', inttostr(crew.CrewID));
	add_row(self.grid_crew, 'GpsID', inttostr(crew.GpsId));
	add_row(self.grid_crew, 'State', inttostr(crew.state));
	add_row(self.grid_crew, 'State_as_string', crew.state_as_string);
	add_row(self.grid_crew, 'Name', crew.name);
	add_row(self.grid_crew, 'Coord', crew.coord);
	add_row(self.grid_crew, 'OrderID', inttostr(crew.OrderId));

	// координаты
	with self.grid_coords do
	begin
		rowcount := 0;
		rows[0].Clear();
		colcount := 2;
		ColWidths[0] := 120;
		ColWidths[1] := Width - ColWidths[0] - 20;
	end;
	for i := 0 to crew.coords.Count - 1 do
		add_row(self.grid_coords, crew.coords_times.Strings[i], crew.coords.Strings[i]);
	with self.grid_coords do
		if rowcount > 1 then
			rowcount := rowcount - 1;

	self.Show();


	// CrewID : Integer;
	// GpsId : Integer;
	// state : Integer; // состояние: 1 - свободен, 3 - на заказе;
	// state_as_string : string;
	// Code : string;
	// name : string;
	// coord : string; // текущая (самая свежая) координата GPS
	// dist : double; // расстояние до адреса подачи (АП) радиальное, по прямой, метров;
	// dist_way : double; // длина маршрута до АП, км;
	// dist_way_as_string : string; // то же;
	// time : Integer; // время подъезда к АП в минутах;
	// time_as_string : string; // оно же в виде часы-минуты;
	// coords : TStringList; // gps-трек за выбранный промежуток времени;
	// coords_times : TStringList; // gps-трек за выбранный промежуток времени;
	// // coord_list : TStringList;
	// OrderId : Integer; // ID заказа занятого экипажа
	// order_way : string; // маршрут занятого экипажа
	//
	// source : TAdres; // address_from for state==3
	// dest : TAdres; // address_to for state==3
	// ap : TAdres; // адрес подачи экипажа

end;

end.
