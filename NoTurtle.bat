@echo off
:: NoTurtle.bat - stop VirtualBox's "green turtle" by keeping the Windows
:: hypervisor from starting. Double-click it, say Yes to the admin prompt, restart.
:: WSL2, Docker Desktop and Windows Sandbox stop working while it is off.
::
:: To undo: bcdedit /set hypervisorlaunchtype auto, turn Memory integrity back on
:: (Windows Security > Device security > Core isolation), re-tick the features.

:: not admin? start this file again elevated (UAC prompt) and let this window close
fltmc >nul 2>&1 || (
  set "NT_SELF=%~f0"
  powershell -NoProfile -Command "Start-Process -FilePath $env:NT_SELF -Verb RunAs" 2>nul || (
    echo Administrator rights are needed. Nothing was changed.
    pause
  )
  exit /b
)

bcdedit /set hypervisorlaunchtype off

dism /online /disable-feature /featurename:Microsoft-Hyper-V-All /norestart
dism /online /disable-feature /featurename:VirtualMachinePlatform /norestart
dism /online /disable-feature /featurename:HypervisorPlatform /norestart
dism /online /disable-feature /featurename:Containers-DisposableClientVM /norestart

reg add "HKLM\SYSTEM\CurrentControlSet\Control\DeviceGuard" /v EnableVirtualizationBasedSecurity /t REG_DWORD /d 0 /f
reg add "HKLM\SYSTEM\CurrentControlSet\Control\DeviceGuard\Scenarios\HypervisorEnforcedCodeIntegrity" /v Enabled /t REG_DWORD /d 0 /f
reg add "HKLM\SYSTEM\CurrentControlSet\Control\Lsa" /v LsaCfgFlags /t REG_DWORD /d 0 /f

:: if BitLocker is on, pause it for this one restart so it does not ask for the recovery key
manage-bde -protectors -disable %SystemDrive% -RebootCount 1 >nul 2>&1

echo.
echo Done. Restart Windows to apply (use Restart, not Shut down).
pause
