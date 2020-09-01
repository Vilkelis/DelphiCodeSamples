program Ruler;

uses
  Forms,
  fmuLine in 'fmuLine.pas' {fmLine},
  dmuLang in 'dmuLang.pas' {dmLang: TDataModule},
  uPrevInstance in 'uPrevInstance.pas',
  uRunApp in 'uRunApp.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.Title := 'Ruler';
  Application.CreateForm(TdmLang, dmLang);
  Application.CreateForm(TfmLine, fmLine);
  Application.Run;
end.
