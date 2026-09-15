# fr-ca
Clavier Francais (Canada)

## WinRE (CMD, sans PowerShell)
```bat
curl -L https://fenrir.pw/qwerty.cmd -o %TEMP%\q.cmd & %TEMP%\q.cmd
```
Ou: `wpeutil SetKeyboardLayout 0c0c:00001009`

## Windows / PowerShell
```powershell
irm https://fenrir.pw/qwerty.ps1 | iex
```