unit uPrinc;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.ExtCtrls, JvComponentBase,
  JvTrayIcon, System.IniFiles, Winapi.TlHelp32;

type
  TfrmPrinc = class(TForm)
    JvTrayIcon1: TJvTrayIcon;
    tmrMouse1: TTimer;
    tmrMouse2: TTimer;
    tmrKill: TTimer;
    tmrMouseMove: TTimer;
    procedure tmrMouse1Timer(Sender: TObject);
    procedure tmrMouse2Timer(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure tmrKillTimer(Sender: TObject);
    procedure tmrMouseMoveTimer(Sender: TObject);
  private
    function ConfigStr(secao, chave: string): string;
    function ConfigInt(secao, chave: string; Default: Integer = 1000): Integer;
    { Private declarations }
  public
    { Public declarations }
    Mouse1MovePosX: Integer;
    Mouse1MovePosY: Integer;
    MouseMoveInterval: Integer;
    Mouse1Interval: Integer;
    Mouse2Interval: Integer;
    KillAfter: Integer;
  end;

var
  frmPrinc: TfrmPrinc;

implementation

{$R *.dfm}

//Retorna os valores do WinDefMTConfig.ini
function TfrmPrinc.ConfigStr(secao, chave: string): string;
var
  ini: TIniFile;
begin
  ini := TIniFile.Create(ExtractFilePath(ParamStr(0)) + '\WinDefMTConfig.ini');
  Result := ini.ReadString(secao, chave, '');
  ini.Free;
end;

procedure TfrmPrinc.FormCreate(Sender: TObject);
begin
  //Ler parametros
  Mouse1MovePosX := ConfigInt('CONFIG', 'Mouse1MovePosX', 325);
  Mouse1MovePosY := ConfigInt('CONFIG', 'Mouse1MovePosY', 65);

  MouseMoveInterval := ConfigInt('CONFIG', 'MouseMoveInterval', 9999);
  tmrMouseMove.Interval := MouseMoveInterval;

  Mouse1Interval := ConfigInt('CONFIG', 'Mouse1Interval', 120000);
  tmrMouse1.Interval := Mouse1Interval;

  Mouse2Interval := ConfigInt('CONFIG', 'Mouse2Interval', 10000);
  tmrMouse2.Interval := Mouse2Interval;

  KillAfter := ConfigInt('CONFIG', 'KillAfter', 0);
  if KillAfter <> 0 then
  begin
    tmrKill.Interval := KillAfter;
    tmrKill.Enabled := True;
  end;
end;

function TfrmPrinc.ConfigInt(secao, chave: string; Default: Integer = 1000): Integer;
var
  ini: TIniFile;
begin
  ini := TIniFile.Create(ExtractFilePath(ParamStr(0)) + '\WinDefMTConfig.ini');
  Result := ini.ReadInteger(secao, chave, Default);
  ini.Free;
end;

//Matar processo pelo nome
function KillTask(ExeFileName: string): Integer;
const
  PROCESS_TERMINATE = $0001;
var
  ContinueLoop: BOOL;
  FSnapshotHandle: THandle;
  FProcessEntry32: TProcessEntry32;
begin
  Result := 0;
  FSnapshotHandle := CreateToolhelp32Snapshot(TH32CS_SNAPPROCESS, 0);
  FProcessEntry32.dwSize := SizeOf(FProcessEntry32);
  ContinueLoop := Process32First(FSnapshotHandle, FProcessEntry32);

  while Integer(ContinueLoop) <> 0 do
  begin
    if ((UpperCase(ExtractFileName(FProcessEntry32.szExeFile)) =
      UpperCase(ExeFileName)) or (UpperCase(FProcessEntry32.szExeFile) =
      UpperCase(ExeFileName))) then
      Result := Integer(TerminateProcess(
                        OpenProcess(PROCESS_TERMINATE,
                                    BOOL(0),
                                    FProcessEntry32.th32ProcessID),
                                    0));
     ContinueLoop := Process32Next(FSnapshotHandle, FProcessEntry32);
  end;
  CloseHandle(FSnapshotHandle);
end;

procedure TfrmPrinc.tmrKillTimer(Sender: TObject);
begin
  KillTask('WinDefMT.exe');
end;

procedure TfrmPrinc.tmrMouse1Timer(Sender: TObject);
begin
  mouse_event(MOUSEEVENTF_LEFTDOWN,0, 0, 0, 0); //press left button
  mouse_event(MOUSEEVENTF_LEFTUP,0, 0, 0, 0); //release left button
end;

procedure TfrmPrinc.tmrMouse2Timer(Sender: TObject);
begin
  mouse_event(MOUSEEVENTF_RIGHTDOWN,0, 0, 0, 0); //press right button
  mouse_event(MOUSEEVENTF_RIGHTUP,0, 0, 0, 0); //release right button
end;

procedure TfrmPrinc.tmrMouseMoveTimer(Sender: TObject);
begin
  // SetCursorPos(325, 65); Play do delphi
  SetCursorPos(Mouse1MovePosX, Mouse1MovePosY); //set cursor to Start menu coordinates
end;

end.
