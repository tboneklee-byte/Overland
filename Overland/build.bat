@echo off
setlocal enabledelayedexpansion
title Overland - serve / package helper
cd /d "%~dp0"

REM --- find a python launcher (you already run pc_remote.py, so this should exist) ---
set "PY="
where py >nul 2>&1 && set "PY=py"
if not defined PY ( where python >nul 2>&1 && set "PY=python" )

:menu
cls
echo ==================================================
echo    OVERLAND  -  serve / package helper
echo ==================================================
echo.
echo   These are static web files. Nothing to compile -
echo   they just need to be SERVED (to test) or ZIPPED
echo   (to upload to Netlify Drop).
echo.
echo   [1]  Serve locally + open browser   (localhost:8000)
echo   [2]  Make deploy zip                (overland.zip)
echo   [3]  Quit
echo.
set /p "choice=Choose 1-3: "

if "%choice%"=="1" goto serve
if "%choice%"=="2" goto zip
if "%choice%"=="3" goto end
goto menu

:serve
if not defined PY (
  echo.
  echo   ! Python not found on PATH. Install Python, or just use
  echo     your deployed Netlify URL on the phone instead.
  echo.
  pause
  goto menu
)
echo.
echo   Serving this folder at  http://localhost:8000
echo   ( Service worker + GPS work on localhost. If the tab
echo     is blank, give it a second and refresh. )
echo.
echo   Press Ctrl+C to stop the server and return here.
echo.
start "" http://localhost:8000
%PY% -m http.server 8000
goto menu

:zip
echo.
echo   Packaging index.html, sw.js, manifest.json, icon.png  ->  overland.zip
powershell -NoProfile -Command "Compress-Archive -Force -Path 'index.html','sw.js','manifest.json','icon.png' -DestinationPath 'overland.zip'"
if exist overland.zip (
  echo.
  echo   Done.  Drag  overland.zip  onto  https://app.netlify.com/drop
) else (
  echo.
  echo   ! Could not create overland.zip - check the files are in this folder.
)
echo.
pause
goto menu

:end
endlocal
