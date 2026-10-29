; Paintbox's Windows installer (Inno Setup 6). tools/package-windows.ps1 runs
; ISCC with /DAppVersion, /DSourceDir (the release build) and /DOutputDir;
; without Inno Setup on the machine it skips this and makes the zip and
; the MSIX only. Per-user by default (no administrator rights needed);
; the dialog offers all users.

#ifndef AppVersion
  #define AppVersion "0.0.0"
#endif
#ifndef SourceDir
  #define SourceDir "..\..\app\build\windows\x64\runner\Release"
#endif
#ifndef OutputDir
  #define OutputDir "..\..\dist"
#endif

[Setup]
AppId={{6F3B2A41-7C1D-4E8A-9B55-2D0C6A1E9F70}
AppName=Paintbox
AppVersion={#AppVersion}
AppPublisher=Paintbox
DefaultDirName={autopf}\Paintbox
DefaultGroupName=Paintbox
DisableProgramGroupPage=yes
PrivilegesRequired=lowest
PrivilegesRequiredOverridesAllowed=dialog
ArchitecturesAllowed=x64compatible
ArchitecturesInstallIn64BitMode=x64compatible
OutputDir={#OutputDir}
OutputBaseFilename=Paintbox-{#AppVersion}-windows-x64-setup
SetupIconFile=..\..\app\windows\runner\resources\app_icon.ico
UninstallDisplayIcon={app}\paintbox.exe
Compression=lzma2
SolidCompression=yes
WizardStyle=modern
ChangesAssociations=yes

[Languages]
Name: "en"; MessagesFile: "compiler:Default.isl"
Name: "uk"; MessagesFile: "compiler:Languages\Ukrainian.isl"

[Tasks]
Name: "desktopicon"; Description: "{cm:CreateDesktopIcon}"; GroupDescription: "{cm:AdditionalIcons}"; Flags: unchecked
Name: "openraster"; Description: "OpenRaster (.ora)"; GroupDescription: "{cm:AssocFileExtension,Paintbox,.ora}"

[Files]
; A debug run's kernel left in build/flutter_assets is not needed by the AOT build.
Source: "{#SourceDir}\*"; DestDir: "{app}"; Excludes: "kernel_blob.bin"; Flags: ignoreversion recursesubdirs createallsubdirs

[Icons]
Name: "{autoprograms}\Paintbox"; Filename: "{app}\paintbox.exe"
Name: "{autodesktop}\Paintbox"; Filename: "{app}\paintbox.exe"; Tasks: desktopicon

[Registry]
Root: HKA; Subkey: "Software\Classes\.ora\OpenWithProgids"; ValueType: string; ValueName: "Paintbox.ora"; ValueData: ""; Flags: uninsdeletevalue; Tasks: openraster
Root: HKA; Subkey: "Software\Classes\Paintbox.ora"; ValueType: string; ValueName: ""; ValueData: "OpenRaster image"; Flags: uninsdeletekey; Tasks: openraster
Root: HKA; Subkey: "Software\Classes\Paintbox.ora\DefaultIcon"; ValueType: string; ValueName: ""; ValueData: "{app}\paintbox.exe,0"; Tasks: openraster
Root: HKA; Subkey: "Software\Classes\Paintbox.ora\shell\open\command"; ValueType: string; ValueName: ""; ValueData: """{app}\paintbox.exe"" ""%1"""; Tasks: openraster

[Run]
Filename: "{app}\paintbox.exe"; Description: "{cm:LaunchProgram,Paintbox}"; Flags: nowait postinstall skipifsilent
