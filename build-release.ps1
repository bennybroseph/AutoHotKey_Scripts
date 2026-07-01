<#
    build-release.ps1 — builds the ConfigurationForm app and stages a complete
    release under ConfigurationForm\ConfigurationForm\bin\Release.

    Pipeline:
      1. (manual, done first) Recompile the AutoHotkey exe — see release notes.
      2. This script builds the C# app in Release; the csproj copies the AHK exe,
         runtime DLLs, loose thread scripts, Images, Settings, and config into the
         output, so bin\Release is the full distributable.

    Requires MSBuild (VS 2022 / Build Tools). No .NET Framework Developer Pack
    needed: the net48 reference assemblies are pulled from NuGet on first run.
#>
[CmdletBinding()]
param(
    [string]$Configuration = 'Release'
)
$ErrorActionPreference = 'Stop'
$repo = $PSScriptRoot
$sln  = Join-Path $repo 'ConfigurationForm\ConfigurationForm.sln'
$ahkExe    = Join-Path $repo 'ConfigurationForm\ConfigurationForm\AutoHotkey\Joystick to Keyboard Emulation.exe'
$ahkSource = Join-Path $repo 'ConfigurationForm\ConfigurationForm\AutoHotkey\Library\XInput.ahk'

# --- Locate MSBuild via vswhere ---
$vswhere = "${env:ProgramFiles(x86)}\Microsoft Visual Studio\Installer\vswhere.exe"
if (-not (Test-Path $vswhere)) { throw "vswhere not found; install Visual Studio 2022 or Build Tools." }
$msbuild = & $vswhere -latest -requires Microsoft.Component.MSBuild -find 'MSBuild\**\Bin\MSBuild.exe' | Select-Object -First 1
if (-not $msbuild) { throw "MSBuild not found via vswhere." }

# --- Ensure net48 reference assemblies (no Developer Pack required) ---
$refPkgDir = Join-Path $repo '.tools\net48refs'
$refRoot   = Join-Path $refPkgDir 'build'
if (-not (Test-Path (Join-Path $refRoot '.NETFramework\v4.8\mscorlib.dll'))) {
    Write-Host 'Fetching net48 reference assemblies from NuGet...'
    New-Item -ItemType Directory -Force $refPkgDir | Out-Null
    $nupkg = Join-Path $refPkgDir 'pkg.zip'
    Invoke-WebRequest 'https://www.nuget.org/api/v2/package/Microsoft.NETFramework.ReferenceAssemblies.net48/1.0.3' -OutFile $nupkg -UseBasicParsing
    Expand-Archive $nupkg -DestinationPath $refPkgDir -Force
    Remove-Item $nupkg
}

# --- Warn if the AHK exe looks stale relative to its source (recompile step skipped?) ---
if ((Test-Path $ahkExe) -and (Test-Path $ahkSource) -and
    ((Get-Item $ahkSource).LastWriteTime -gt (Get-Item $ahkExe).LastWriteTime)) {
    Write-Warning "XInput.ahk is newer than the compiled AHK exe. Recompile the Joystick to Keyboard Emulation script with AutoHotkey_H Ahk2Exe before releasing, or the fix will not ship."
}

# --- Build ---
Write-Host "Building $Configuration ..."
& $msbuild $sln /t:Restore,Build /p:Configuration=$Configuration "/p:TargetFrameworkRootPath=$refRoot" /v:minimal /nologo
if ($LASTEXITCODE -ne 0) { throw "Build failed (exit $LASTEXITCODE)." }

$out = Join-Path $repo "ConfigurationForm\ConfigurationForm\bin\$Configuration"
Write-Host "`nDone. Distributable staged at:`n  $out" -ForegroundColor Green
