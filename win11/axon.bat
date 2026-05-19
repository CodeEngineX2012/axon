@echo off
setlocal EnableDelayedExpansion

color 0A

set HISTFILE=%USERPROFILE%\.axonhist

cls

echo Axon
echo built by Skyzen Labs

:main
set /p user_input=^> 

if "%user_input%"=="" goto main

echo %user_input%>>"%HISTFILE%"

if "%user_input%"=="help" (
    echo help                                  : Show this menu
    echo axon /start --agent-services          : Start agent services
    echo axon /start --agent-mode webui        : Run Agents in WebUI mode
    echo axon /open -h                         : Show the /open help menu
    goto main
)

if "%user_input%"=="axon /open -h" (
    echo axon /open -h                         : Show this menu
    echo axon /open .mail                      : Opens configured mail site
    echo axon /open .instagram                 : Opens Instagram
    echo axon /open .facebook                  : Opens Facebook
    goto main
)

if "%user_input%"=="axon /open .instagram" (
    echo Opening Instagram....
    set "INSTAGRAM_LINK=" REM Clear variable before use
    for /f "tokens=2 delims==" %%A in ('findstr "^site=" configs\social\instagram.axconf') do (
        set INSTAGRAM_LINK=%%A
    )
    if not defined INSTAGRAM_LINK (
        echo Error: Instagram link not found in config.
    ) else (
        start "" "!INSTAGRAM_LINK!"
    )
    goto main
)

if "%user_input%"=="axon /open dash.ui" (
    echo Opening DashboardUI....
    REM Start Python HTTP server in 'ui' directory in a new cmd window
    start cmd /k "cd /d ui && python -m http.server"

    set "LIVE_SERVER=" REM Clear variable before use
    for /f "tokens=2 delims==" %%A in ('findstr "^lveserver=" configs\dash\monc.axconf') do (
        set LIVE_SERVER=%%A
    )
    if not defined LIVE_SERVER (
        echo Error: Live server link not found in config.
    ) else (
        start "" "!LIVE_SERVER!"
    )
    goto main
)

if "%user_input%"=="axon /run shortcuts.cl" (
    echo Running shortcuts.axcl
    REM This block is identical to "axon /open dash.ui".
    REM Assuming it's intended to do the same thing, applying the same fix.
    start cmd /k "cd /d ui && python -m http.server"

    set "LIVE_SERVER=" REM Clear variable before use
    for /f "tokens=2 delims==" %%A in ('findstr "^lveserver=" configs\dash\monc.axconf') do (
        set LIVE_SERVER=%%A
    )
    if not defined LIVE_SERVER (
        echo Error: Live server link not found in config.
    ) else (
        start "" "!LIVE_SERVER!"
    )
    goto main
)

if "%user_input%"=="axon /start --agent-services" (
    echo Checking for system updates.....

    set "UPDATE_URL=https://axonagents.netlify.app/updates/latest/updates.axup"
    powershell -Command "Invoke-WebRequest -Uri '!UPDATE_URL!' -OutFile '%TEMP%\updates.axup'"

    if exist "%TEMP%\updates.axup" (
        set "NEW="
        set "VERSION_NAME="
        set "VERSION_CODE="
        set "RELEASE_TIME="

        for /f "tokens=2 delims==" %%A in ('findstr "^new=" "%TEMP%\updates.axup"') do set NEW=%%A
        for /f "tokens=2 delims==" %%A in ('findstr "^version_name=" "%TEMP%\updates.axup"') do set VERSION_NAME=%%A
        for /f "tokens=2 delims==" %%A in ('findstr "^version_code=" "%TEMP%\updates.axup"') do set VERSION_CODE=%%A
        for /f "tokens=2 delims==" %%A in ('findstr "^release_time=" "%TEMP%\updates.axup"') do set RELEASE_TIME=%%A

        if /I "!NEW!"=="true" (
            echo ====================================
            echo  Update Available!
            echo ------------------------------------
            echo  Version Name : !VERSION_NAME!
            echo  Version Code : !VERSION_CODE!
            echo  Release Time : !RELEASE_TIME!
            echo  Status       : AVAILABLE
            echo ====================================

            set /p choice=Would you like to update? (Y/N):
            if /I "!choice!"=="Y" (
                set "ZIP_URL=https://axonagents.netlify.app/updates/latest/!VERSION_NAME!.zip"
                echo Downloading update package...
                REM The update ZIP will be saved in the current directory. Consider saving to %TEMP%
                powershell -Command "Invoke-WebRequest -Uri '!ZIP_URL!' -OutFile '!VERSION_NAME!.zip'"
                if exist "!VERSION_NAME!.zip" (
                    echo Update package downloaded successfully!
                    echo Saved as: !VERSION_NAME!.zip
                ) else (
                    echo Failed to download update package.
                )
            ) else (
                echo Update cancelled.
            )
        ) else (
            echo No new updates available.
        )
        del "%TEMP%\updates.axup" 2>nul REM Clean up downloaded update info file
    ) else (
        echo Could not check for updates. Make sure you have an internet connection.
    )
    goto main
)

if "%user_input%"=="restart" (
    cls
    start "" "%~f0"
    exit
)

if "%user_input%"=="exit" (
    exit
)

if "%user_input%"=="clear" (
    cls
    goto main
)

echo Command not recognized. Try "help"
goto main