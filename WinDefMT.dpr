program WinDefMT;

uses
  Vcl.Forms,
  uPrinc in 'uPrinc.pas' {frmPrinc};

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TfrmPrinc, frmPrinc);
  Application.ShowMainForm := False;
  Application.Run;
end.
