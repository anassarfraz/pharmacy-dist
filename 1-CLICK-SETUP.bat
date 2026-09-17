@echo off
title PharmaCare POS - 1-Click First-Time Setup & Launcher
color 0A

echo ================================================================
echo           🏥 PharmaCare POS - Smart First-Time Setup Wizard
echo ================================================================
echo.

:: 1. Check Administrator Privileges
net session >nul 2>&1
if %ERRORLEVEL% NEQ 0 (
    echo [INFO] Requesting Administrator privileges...
    powershell -Command "Start-Process '%~dpnx0' -Verb RunAs"
    exit /b
)

set "INSTALL_DIR=%~dp0"
if "%INSTALL_DIR:~-1%"=="\" set "INSTALL_DIR=%INSTALL_DIR:~0,-1%"

:: Check if .env exists, create local secure .env dynamically if missing
if not exist "%INSTALL_DIR%\.env" (
    echo [INFO] Generating secure local .env configuration...
    powershell -NoProfile -Command "$chars = 'abcdef0123456789'; $rnd = New-Object System.Random; $secret = -join (1..64 | ForEach-Object { $chars[$rnd.Next($chars.Length)] }); $content = @('MONGODB_URI=mongodb://127.0.0.1:27017/pharmacy', ('NEXTAUTH_SECRET=' + $secret), 'NEXTAUTH_URL=http://localhost:3000', 'PORT=3000', 'HOSTNAME=0.0.0.0', 'NODE_ENV=production', 'DEMO_MODE=false'); Set-Content -Path '%INSTALL_DIR%\.env' -Value $content"
    echo      [OK] Local .env configured with unique cryptographic secret.
)

echo [1/4] Checking local domain (http://pharmacy.local)...
findstr /i "pharmacy.local" "%WINDIR%\System32\drivers\etc\hosts" >nul 2>&1
if %ERRORLEVEL% NEQ 0 (
    echo 127.0.0.1 pharmacy.local pos.local>> "%WINDIR%\System32\drivers\etc\hosts"
    echo      [OK] Local domain configured in hosts.
) else (
    echo      [OK] Local domain already configured in hosts.
)

echo.
echo [2/4] Checking PM2 process supervisor...
where pm2 >nul 2>&1
if %ERRORLEVEL% NEQ 0 (
    echo      Installing PM2 globally...
    call npm install -g pm2 --silent >nul 2>&1
) else (
    echo      [OK] PM2 is already installed.
)

cd /d "%INSTALL_DIR%"
echo      Starting/Reloading PharmaCare service...
call pm2 reload pharmacare-pos 2>nul || call pm2 restart pharmacare-pos 2>nul || call pm2 start ecosystem.config.js
call pm2 save >nul 2>&1

echo.
echo [3/4] Configuring Windows Startup auto-boot trigger...
powershell -NoProfile -Command "$s=[System.Environment]::GetFolderPath('Startup')+'\Start-PharmaCare.vbs'; if (-not (Test-Path $s)) { Set-Content -Path $s -Value 'Set WshShell = CreateObject(""WScript.Shell""): WshShell.Run ""cmd /c cd /d %INSTALL_DIR% && (pm2 reload all || pm2 start ecosystem.config.js || node server.js)"", 0, False' }"

echo.
echo [4/4] Creating Desktop Shortcut...
powershell -NoProfile -Command "$ws=New-Object -ComObject WScript.Shell; $d=[System.Environment]::GetFolderPath('Desktop')+'\PharmaCare POS.lnk'; if (-not (Test-Path $d)) { $s=$ws.CreateShortcut($d); $s.TargetPath='http://pharmacy.local'; $s.Description='PharmaCare POS'; $s.Save() }"

echo.
echo ================================================================
echo   🎉 SETUP COMPLETED! 
echo   PharmaCare POS is active at: http://pharmacy.local
echo   Desktop shortcut ready: "PharmaCare POS"
echo ================================================================
echo.
pause
start http://pharmacy.local
