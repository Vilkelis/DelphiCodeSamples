program MCalc;

uses
  Forms,
  uMain in 'uMain.pas' {fmMain},
  uStorage in 'uStorage.pas',
  uLib in 'uLib.pas',
  QStrings in 'QStrings.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.Title := 'Металл Калькулятор';
  Application.CreateForm(TfmMain, fmMain);
  Application.Run;
end.
