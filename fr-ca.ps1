# fr-CA keyboard helper (WinRE + Windows)
# Usage: irm <url> | iex
$ErrorActionPreference = "Continue"
try { chcp 65001 | Out-Null } catch {}

Write-Host "=== Clavier Francais (Canada) ===" -ForegroundColor Cyan

function Test-WinRE {
  if ($env:SystemDrive -eq "X:") { return $true }
  if (Get-Command wpeutil.exe -ErrorAction SilentlyContinue) {
    if (-not (Test-Path "$env:SystemRoot\Explorer.exe")) { return $true }
  }
  return $false
}

$ok = $false

# 1) WinRE / Windows PE
if (Get-Command wpeutil.exe -ErrorAction SilentlyContinue) {
  Write-Host "wpeutil SetKeyboardLayout 0c0c:00001009 (fr-CA / Canadian French)" -ForegroundColor Yellow
  & wpeutil.exe SetKeyboardLayout 0c0c:00001009
  if ($LASTEXITCODE -eq 0) {
    Write-Host "OK (WinRE/PE)" -ForegroundColor Green
    $ok = $true
  } else {
    Write-Host "wpeutil code=$LASTEXITCODE — essai layout alternatif..." -ForegroundColor Yellow
    & wpeutil.exe SetKeyboardLayout 0c0c:00011009
    if ($LASTEXITCODE -eq 0) {
      Write-Host "OK (Canadian Multilingual Standard)" -ForegroundColor Green
      $ok = $true
    }
  }
}

# 2) Windows complet (si cmdlets dispo)
try {
  $list = New-WinUserLanguageList fr-CA
  # Tip: 0C0C:00001009 = Francais Canada + Canadian French keyboard
  try {
    $list[0].InputMethodTips.Clear()
    $list[0].InputMethodTips.Add("0C0C:00001009")
  } catch {}
  Set-WinUserLanguageList $list -Force
  try { Set-WinSystemLocale -SystemLocale fr-CA -ErrorAction SilentlyContinue } catch {}
  try { Set-WinUILanguageOverride -Language fr-CA -ErrorAction SilentlyContinue } catch {}
  Write-Host "OK (Windows: langue utilisateur fr-CA)" -ForegroundColor Green
  $ok = $true
} catch {
  if (-not $ok) {
    Write-Host "Set-WinUserLanguageList indisponible ici: $($_.Exception.Message)" -ForegroundColor DarkYellow
  }
}

# 3) Session courante (LoadKeyboardLayout) — utile meme en console
try {
  Add-Type @"
using System;
using System.Runtime.InteropServices;
public class Kb {
  [DllImport("user32.dll")] public static extern IntPtr LoadKeyboardLayout(string pwszKLID, uint Flags);
  [DllImport("user32.dll")] public static extern bool PostMessage(IntPtr hWnd, uint Msg, IntPtr wParam, IntPtr lParam);
  [DllImport("user32.dll")] public static extern IntPtr GetForegroundWindow();
  public const uint KLF_ACTIVATE = 1;
  public const uint WM_INPUTLANGCHANGEREQUEST = 0x0050;
}
"@
  # 00001009 = Canadian French
  [void][Kb]::LoadKeyboardLayout("00001009", [Kb]::KLF_ACTIVATE)
  $hwnd = [Kb]::GetForegroundWindow()
  [void][Kb]::PostMessage($hwnd, [Kb]::WM_INPUTLANGCHANGEREQUEST, [IntPtr]::Zero, [IntPtr]0x1009)
  Write-Host "OK (layout session 00001009)" -ForegroundColor Green
  $ok = $true
} catch {
  Write-Host "LoadKeyboardLayout: $($_.Exception.Message)" -ForegroundColor DarkYellow
}

if ($ok) {
  Write-Host ""
  Write-Host "Clavier fr-CA applique. Teste: azerty-style Canada (qwerty avec accents)." -ForegroundColor Cyan
  Write-Host "Si ca ne change pas tout de suite, bascule avec Win+Espace (Windows) ou reouvre l'invite." -ForegroundColor DarkGray
} else {
  Write-Host ""
  Write-Host "Echec. Essaie manuellement:" -ForegroundColor Red
  Write-Host "  wpeutil SetKeyboardLayout 0c0c:00001009"
}

Write-Host ""