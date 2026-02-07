@echo off
REM ============================================================================
REM Microcontroller-Based Vending Machine Controller
REM Master Startup Script
REM ============================================================================

cls
echo.
echo ========================================================================
echo  Microcontroller-Based Vending Machine Controller
echo  Interactive Demo Launcher
echo ========================================================================
echo.
echo  Opening interactive demonstration in your default browser...
echo.
echo  Keyboard Shortcuts:
echo    [5] - Insert Rs.5 coin
echo    [1] - Insert Rs.10 coin  
echo    [S] - Select item
echo    [R] - Reset system
echo    [D] - Run auto demo
echo    [Space] - Next cycle (in step mode)
echo.
echo ========================================================================
echo.

REM Open the website in default browser
start "" "%~dp0website\index.html"

echo  Demo launched successfully!
echo.
echo  Press any key to close this window...
pause >nul
