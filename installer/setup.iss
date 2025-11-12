; Script Inno Setup para Workshop Shelf Helper
; Este script cria um instalador Windows completo com:
; - Solicita privilégios de administrador
; - Permite escolha do diretório de instalação
; - Preserva banco de dados durante atualização
; - Cria atalhos no Desktop e Menu Iniciar
; - Desinstala versão anterior automaticamente

#define MyAppName "Workshop Shelf Helper"
#define MyAppVersion "1.0.0"
#define MyAppPublisher "Sua Empresa"
#define MyAppExeName "app_organizador_oficina.exe"
#define MyAppAssocName MyAppName + " File"
#define MyAppAssocExt ".wsf"
#define MyAppAssocKey StringChange(MyAppAssocName, " ", "") + MyAppAssocExt

[Setup]
; Informações do aplicativo
AppId={{E5B8C9D1-2F4A-4B1E-9C3D-5E7F8A9B0C1D}
AppName={#MyAppName}
AppVersion={#MyAppVersion}
AppPublisher={#MyAppPublisher}
DefaultDirName={autopf}\{#MyAppName}
DisableProgramGroupPage=yes
; Solicita privilégios de administrador
PrivilegesRequired=admin
; Permite ao usuário escolher o diretório de instalação
DisableDirPage=no
OutputDir=..\output
OutputBaseFilename=WorkshopShelfHelper-Setup-{#MyAppVersion}
SetupIconFile=..\windows\runner\resources\app_icon.ico
Compression=lzma
SolidCompression=yes
WizardStyle=modern
; Desinstala versão anterior automaticamente
UninstallDisplayIcon={app}\{#MyAppExeName}
DisableWelcomePage=no

[Languages]
Name: "brazilianportuguese"; MessagesFile: "compiler:Languages\BrazilianPortuguese.isl"

[Tasks]
Name: "desktopicon"; Description: "{cm:CreateDesktopIcon}"; GroupDescription: "{cm:AdditionalIcons}"; Flags: unchecked

[Files]
; Inclui todo o conteúdo da pasta Release do build Flutter, EXCETO arquivos .db
; Arquivos .db nunca são copiados do instalador, apenas preservados se já existirem no destino
Source: "..\build\windows\x64\runner\Release\*"; DestDir: "{app}"; Excludes: "*.db"; Flags: ignoreversion recursesubdirs createallsubdirs

[Icons]
Name: "{autoprograms}\{#MyAppName}"; Filename: "{app}\{#MyAppExeName}"
Name: "{autodesktop}\{#MyAppName}"; Filename: "{app}\{#MyAppExeName}"; Tasks: desktopicon

[Run]
Filename: "{app}\{#MyAppExeName}"; Description: "{cm:LaunchProgram,{#StringChange(MyAppName, '&', '&&')}}"; Flags: nowait postinstall skipifsilent

[UninstallDelete]
; Remove apenas arquivos temporários durante desinstalação
; IMPORTANTE: Arquivos .db NUNCA são removidos para preservar dados do usuário
Type: filesandordirs; Name: "{app}\data\flutter_assets"

[Code]
// Função para desinstalar versão anterior automaticamente
function GetUninstallString(): String;
var
  sUnInstPath: String;
  sUnInstallString: String;
begin
  sUnInstPath := ExpandConstant('Software\Microsoft\Windows\CurrentVersion\Uninstall\{#emit SetupSetting("AppId")}_is1');
  sUnInstallString := '';
  if not RegQueryStringValue(HKLM, sUnInstPath, 'UninstallString', sUnInstallString) then
    RegQueryStringValue(HKCU, sUnInstPath, 'UninstallString', sUnInstallString);
  Result := sUnInstallString;
end;

function IsUpgrade(): Boolean;
begin
  Result := (GetUninstallString() <> '');
end;

function UnInstallOldVersion(): Integer;
var
  sUnInstallString: String;
  iResultCode: Integer;
begin
  Result := 0;
  sUnInstallString := GetUninstallString();
  if sUnInstallString <> '' then begin
    sUnInstallString := RemoveQuotes(sUnInstallString);
    if Exec(sUnInstallString, '/SILENT /NORESTART /SUPPRESSMSGBOXES','', SW_HIDE, ewWaitUntilTerminated, iResultCode) then
      Result := 3
    else
      Result := 2;
  end else
    Result := 1;
end;

procedure CurStepChanged(CurStep: TSetupStep);
begin
  if (CurStep=ssInstall) then
  begin
    if (IsUpgrade()) then
    begin
      // Desinstala a versão antiga silenciosamente
      // O banco de dados será preservado pois não está na lista de arquivos a desinstalar
      UnInstallOldVersion();
    end;
  end;
end;

// Mensagem customizada ao detectar atualização
// Informa ao usuário que o banco de dados será preservado
function InitializeSetup(): Boolean;
begin
  Result := True;
  if IsUpgrade() then
  begin
    if MsgBox('Uma versão anterior do ' + '{#MyAppName}' + ' foi detectada.' + #13#10#13#10 +
              'A instalação irá atualizar para a nova versão preservando seu banco de dados.' + #13#10#13#10 +
              'Deseja continuar?', mbConfirmation, MB_YESNO) = IDYES then
    begin
      Result := True;
    end
    else
    begin
      Result := False;
    end;
  end;
end;

