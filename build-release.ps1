<#
    build-release.ps1 — builds the ConfigurationForm app, stages the full release
    under ConfigurationForm\ConfigurationForm\bin\Release, and produces a zip in dist\.

    Pipeline:
      1. (manual, do first) Recompile the AutoHotkey exe with AutoHotkey_H Ahk2Exe
         (base x64w_MT, compression/encrypt off), overwriting the exe in
         ConfigurationForm\ConfigurationForm\AutoHotkey.
      2. This script builds the C# app in Release; the csproj copies the AHK exe,
         runtime DLLs, loose thread scripts, Images, Settings, and config into the
         output, so bin\Release is the full distributable.
      3. It strips non-shipping artifacts (test logs, .pdb) and zips the result.

    Usage:
      .\build-release.ps1                 # produces dist\AutoHotkey_Scripts.zip
      .\build-release.ps1 -Version 4.3    # produces dist\AutoHotkey_Scripts_v4.3.zip

    Requires MSBuild (VS 2022 / Build Tools). No .NET Framework Developer Pack
    needed: the net48 reference assemblies are pulled from NuGet on first run.
#>
[CmdletBinding()]
param(
    [string]$Configuration = 'Release',
    [string]$Version = ''
)
$ErrorActionPreference = 'Stop'
$repo   = $PSScriptRoot
$sln    = Join-Path $repo 'ConfigurationForm\ConfigurationForm.sln'
$ahkDir = Join-Path $repo 'ConfigurationForm\ConfigurationForm\AutoHotkey'
$ahkExe = Join-Path $ahkDir 'Joystick to Keyboard Emulation.exe'

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

# --- Warn if the compiled AHK exe is older than any .ahk source (recompile skipped?) ---
if (Test-Path $ahkExe) {
    $newestSrc = Get-ChildItem $ahkDir -Recurse -Filter *.ahk |
        Sort-Object LastWriteTime -Descending | Select-Object -First 1
    if ($newestSrc -and $newestSrc.LastWriteTime -gt (Get-Item $ahkExe).LastWriteTime) {
        Write-Warning "The compiled AHK exe is older than $($newestSrc.Name). Recompile the Joystick to Keyboard Emulation script with AutoHotkey_H Ahk2Exe before releasing, or your changes will not ship."
    }
}

# --- Build ---
Write-Host "Building $Configuration ..."
& $msbuild $sln /t:Restore,Build /p:Configuration=$Configuration "/p:TargetFrameworkRootPath=$refRoot" /v:minimal /nologo
if ($LASTEXITCODE -ne 0) { throw "Build failed (exit $LASTEXITCODE)." }

$out = Join-Path $repo "ConfigurationForm\ConfigurationForm\bin\$Configuration"

# --- Strip artifacts that should not ship ---
Remove-Item (Join-Path $out 'ConfigurationForm.pdb') -Force -ErrorAction SilentlyContinue
$logDir = Join-Path $out 'AutoHotkey\Log'
if (Test-Path $logDir) { Remove-Item $logDir -Recurse -Force }

# --- Zip the distributable into dist\ ---
$dist = Join-Path $repo 'dist'
New-Item -ItemType Directory -Force $dist | Out-Null
$suffix = if ($Version) { "_v$Version" } else { '' }
$zip = Join-Path $dist "AutoHotkey_Scripts$suffix.zip"
if (Test-Path $zip) { Remove-Item $zip -Force }
# Build the zip with forward-slash entry names. Both Compress-Archive and .NET Framework's
# ZipFile.CreateFromDirectory write backslashes on Windows, which some extractors mishandle.
Add-Type -AssemblyName System.IO.Compression
Add-Type -AssemblyName System.IO.Compression.FileSystem
$fs = [System.IO.File]::Open($zip, [System.IO.FileMode]::Create)
try {
    $archive = New-Object System.IO.Compression.ZipArchive($fs, [System.IO.Compression.ZipArchiveMode]::Create)
    try {
        foreach ($file in Get-ChildItem $out -Recurse -File) {
            $rel = $file.FullName.Substring($out.Length + 1).Replace('\', '/')
            $entry = $archive.CreateEntry($rel, [System.IO.Compression.CompressionLevel]::Optimal)
            $es = $entry.Open()
            $in = [System.IO.File]::OpenRead($file.FullName)
            try { $in.CopyTo($es) } finally { $in.Close(); $es.Close() }
        }
    } finally { $archive.Dispose() }
} finally { $fs.Close() }

Write-Host "`nDone." -ForegroundColor Green
Write-Host "  Staged: $out"
Write-Host "  Zip:    $zip"
