@echo off
chcp 65001 >nul 2>&1
echo === Clavier Francais (Canada) ===
where wpeutil >nul 2>&1
if errorlevel 1 (
  echo wpeutil introuvable.
  pause
  exit /b 1
)
echo wpeutil SetKeyboardLayout 0c0c:00001009
wpeutil SetKeyboardLayout 0c0c:00001009
if errorlevel 1 (
  echo Essai layout alternatif 0c0c:00011009 ...
  wpeutil SetKeyboardLayout 0c0c:00011009
)
echo.
echo OK si pas d'erreur. Teste le clavier.
pause