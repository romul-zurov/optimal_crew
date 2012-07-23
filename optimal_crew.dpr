program optimal_crew;

uses
  Forms,
  main in 'main.pas' {form_main},
  crew_utils in 'crew_utils.pas',
  crew in 'crew.pas',
  form_order in 'form_order.pas' {FormOrder},
  crew_globals in 'crew_globals.pas',
  form_debug in 'form_debug.pas' {FormDebug},
  form_crew in 'form_crew.pas' {FormCrew},
  thread_get_times in 'thread_get_times.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(Tform_main, form_main);
  Application.CreateForm(TFormOrder, FormOrder);
  Application.CreateForm(TFormDebug, FormDebug);
  Application.CreateForm(TFormCrew, FormCrew);
  Application.Run;
end.
