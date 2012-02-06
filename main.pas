unit main;

interface

uses
	Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
	Dialogs, Grids, StdCtrls, DB, IBDatabase, DBGrids, ComCtrls, IBCustomDataSet;

type
	Tform_main = class(TForm)
		grid_crews : TStringGrid;
		Label1 : TLabel;
		Label2 : TLabel;
		edit_zakaz4ik : TEdit;
		edit_adres : TEdit;
		Label3 : TLabel;
		Label5 : TLabel;
		Label4 : TLabel;
		db_main : TIBDatabase;
		stbar_main : TStatusBar;
		ta_main : TIBTransaction;
		dataset_main : TIBDataSet;
    DBGrid1: TDBGrid;
    datasource_main: TDataSource;
		procedure FormCreate(Sender : TObject);
	private
		{ Private declarations }
	public
		{ Public declarations }
	end;

var
	form_main : Tform_main;

implementation

{$R *.dfm}

procedure show_status(status : string);
begin
	form_main.stbar_main.Panels[0].Text := status;
end;

procedure show_order_tarifs();
begin
	with form_main do
	begin
		dataset_main.SelectSQL.Clear;
		dataset_main.SelectSQL.Add('select ID, STATE, CODE, NAME from CREWS');
		dataset_main.Open;
		show_status('������ ���������');
		// while not ds_main.Eof do begin
		//
		// end;

	end;
end;

function open_database() : boolean;
begin
	with form_main do
	begin
		with db_main do
		begin
			SQLDialect := 3;
			DatabaseName := 'localhost:D:\fbdb\tme.fdb';
			// DatabaseName := 'localhost:c:\Program Files\TMEnterpriseDemo\tme_demo_db.fdb';
			// LoginPrompt := False;		{off window-prompt user and passwd}
			// Params.Clear;				{see dfm.form_main.db_main.Params}
			// Params.Add('user_name=SYSDBA');
			// Params.Add('password=masterkey');
			// Params.Add('lc_ctype=WIN1251');
		end;
		try
			db_main.Connected := True;
			show_status('�������� ����������� � ��');
			Result := True;
		except
			show_status('������ ��� �������� ��');
			Result := False;
		end;
	end;
end;

procedure Tform_main.FormCreate(Sender : TObject);
begin
	with form_main do
	begin
		grid_crews.ColWidths[0] := 120;
		grid_crews.ColWidths[1] := 180;
		grid_crews.ColWidths[2] := 570 - (120 + 180) - 5;
	end;

	if open_database() then
	begin
		show_order_tarifs();
	end;

end;

end.
