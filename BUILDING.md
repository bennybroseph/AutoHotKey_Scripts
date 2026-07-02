# Building & Releasing

How to build the app and produce a release zip. There are **two build products** that get bundled together:

| Product | What it is | Built with |
|---------|-----------|-----------|
| `Joystick to Keyboard Emulation.exe` | The AutoHotkey engine | **AutoHotkey_H** Ahk2Exe (manual) |
| `ConfigurationForm.exe` | The C# WinForms configurator | MSBuild / `build-release.ps1` |

The AHK exe is compiled by hand and committed into the repo; the build script then packages it together with the C# app.

---

## Prerequisites

- **Visual Studio 2022** (or Build Tools 2022) — for MSBuild.
  - No .NET Framework Developer Pack needed — `build-release.ps1` pulls the net48 reference assemblies from NuGet automatically into `.tools\`.
- **AutoHotkey_H v1** toolkit — from [HotKeyIt/ahkdll-v1-release](https://github.com/HotKeyIt/ahkdll-v1-release). Only needed when you change a `.ahk` file and must recompile the engine.

> ⚠️ **Antivirus:** Ahk2Exe and compiled AHK exes are frequent Defender **false positives**. Add a folder exclusion for your repo (and the AHK toolkit folder) via *Windows Security → Virus & threat protection → Exclusions*. From an **admin** PowerShell:
> ```powershell
> Add-MpPreference -ExclusionPath "D:\Documents\GitHub\AutoHotKey_Scripts"
> Add-MpPreference -ExclusionProcess "Ahk2Exe.exe"
> ```

---

## Step 1 — Recompile the AHK engine (only if a `.ahk` changed)

The script is **AutoHotkey_H** (uses `AHKThread`/`CriticalObject`) — it does **not** run on standard AutoHotkey v1 or v2.

In **Ahk2Exe**:

| Field | Value |
|-------|-------|
| **Source** | `ConfigurationForm\ConfigurationForm\AutoHotkey\Joystick to Keyboard Emulation.ahk` |
| **Destination** | same folder, overwrite the existing `.exe` |
| **Base File** | **`x64w_MT\AutoHotkeySC.bin`** (64-bit, multi-thread) |
| **Compression** | ❌ off |
| **Encrypt** | ❌ off |

> Use the **`.bin`** base, not `AutoHotkey.dll`. Keep compression/encrypt **off** — both dramatically increase AV false-positive rates.

---

## Step 2 — Build & package

From the repo root:

```powershell
.\build-release.ps1 -Version 4.3
```

This builds the C# app in Release, strips the `.pdb` and test logs, and writes **`dist\AutoHotkey_Scripts_v4.3.zip`** — the uploadable release artifact. Omit `-Version` for an unversioned name.

The script warns if the compiled AHK exe is older than any `.ahk` source (i.e. you forgot Step 1).

**To upload:** attach the zip from `dist\` to a GitHub Release. Users extract it and run `ConfigurationForm.exe`.

---

## Notes

- `dist\` and `.tools\` are gitignored (build artifacts / local cache).
- The C# csproj targets **.NET Framework 4.8** and copies the AHK exe, its runtime DLLs, the loose thread scripts (`KeyPressThread`/`KeyReleaseThread`/`MouseThread` + `MouseDelta`/`Delegate`), Images, Settings, and config into the build output — so `bin\Release` is the complete distributable.
- **End users may see an AV warning** on the compiled AHK exe — this is inherent to compiled AutoHotkey and worth mentioning in release notes so they know to allow it.
- **Multiple controllers:** the engine reads only the one XInput device that is actively sending input, so idle/virtual pads (Steam Input, ViGEm, extra controllers) won't interfere.
