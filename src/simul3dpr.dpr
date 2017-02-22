program simul3dpr;

{$IFDEF FPC}
  {$MODE Delphi}
{$ENDIF}

uses
  Forms,
  frm_simul2 in 'frm_simul2.pas' {Form1},
  sim_utils in 'sim_utils.pas',
  tabassoc in 'tabassoc.pas',
  schema_utils in 'schema_utils.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.CreateForm(TForm1, Form1);
  Application.Run;
end.
