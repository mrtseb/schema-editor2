program simul3;

{$IFDEF FPC}
  {$MODE Delphi}
{$ENDIF}

uses
  Forms,
  frm_simul3 in '..\..\..\spice\src\frm_simul3.pas' {Form1},
  sim_utils in '..\..\..\spice\src\sim_utils.pas',
  tabassoc in '..\..\..\spice\src\tabassoc.pas',
  schema_utils in '..\..\..\spice\src\schema_utils.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.CreateForm(TForm1, Form1);
  Application.Run;
end.
