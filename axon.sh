#!/bin/bash

GREEN="\e[32m"
RED="\e[31m"
RESET="\e[0m"

HISTFILE="$HOME/.axonhist"
HISTSIZE=1000
HISTFILESIZE=2000
history -r

echo -e "${GREEN}"
cat << "EOF"
|================================================|
|       _____  ____  ___________    _______      |
|      /  _  \ \   \/  /\_____  \   \      \     |
|     /  /_\  \ \     /  /   |   \  /   |   \    |
|    /    |    \/     \ /    |    \/    |    \   |
|    \____|__  /___/\  \\_______  /\____|__  /   |
|             \/      \_/        \/         \/   |
|                                                |
|================================================|       
EOF
echo -e "${RESET}"
echo -e "${GREEN}built by Skyzen Labs${RESET}"

while true; do
    read -e -p "> " user_input

    [[ -z "$user_input" ]] && continue

    history -s "$user_input"
    history -w

    case "$user_input" in

        "help")
            echo
            echo "help                                  :           Show this menu"
            echo "axon /start --agent-services          :           Start agent services"
            echo "axon /start --agent-mode webui        :           Run Agents in WebUI mode"
            echo "axon /open -h                         :           Show the /open help menu"
            echo "help                                  :           Show this menu"
            echo "help                                  :           Show this menu"
            echo "help                                  :           Show this menu"
            echo
            ;;

        "axon /open -h")
            echo
            echo "axon /open -h                         :           Show this menu"
            echo "axon /open .mail                      :           Opens the default mail application/website, configured in /configs/social/mail.axconf"
            echo "axon /open .instagram                 :           Opens Instagram"
            echo "axon /open .facebook                  :           Opens Facebook"
            echo
            ;;
        
        "axon /open .instagram")
            echo
            echo "Opening Instagram...."
            echo

            INSTAGRAM_LINK=$(grep "^site=" configs/social/instagram.axconf | cut -d'=' -f2-)

            xdg-open "$INSTAGRAM_LINK" >/dev/null 2>&1 &

        ;;

        "axon /open dash.ui")
            echo
            echo "Opening DashboardUI...."
            cd ui
            python3 -m http.server
            cd
            echo

            LIVE_SERVER=$(grep "^lveserver=" configs/dash/monc.axconf | cut -d'=' -f2-)

            xdg-open "$LIVE_SERVER" >/dev/null 2>&1 &

        ;;

        "axon /run shortcuts.cl")
            echo
            echo "Running shortcuts.axcl"
            cd ui
            python3 -m http.server
            cd
            echo

            LIVE_SERVER=$(grep "^lveserver=" configs/dash/monc.axconf | cut -d'=' -f2-)

            xdg-open "$LIVE_SERVER" >/dev/null 2>&1 &

        ;;



"axon /update")
    echo "Checking for system updates....."

    UPDATE_URL="https://axonagents.netlify.app/updates/latest/updates.axup"

    # Download update file temporarily
    curl -s "$UPDATE_URL" -o /tmp/updates.axup

    # Check if file downloaded
    if [ -f /tmp/updates.axup ]; then

        # Read values from file
        NEW=$(grep "new=" /tmp/updates.axup | cut -d'=' -f2)
        VERSION_NAME=$(grep "version_name=" /tmp/updates.axup | cut -d'=' -f2)
        VERSION_CODE=$(grep "version_code=" /tmp/updates.axup | cut -d'=' -f2)
        RELEASE_TIME=$(grep "release_time=" /tmp/updates.axup | cut -d'=' -f2)

        # Check if update is enabled
        if [ "$NEW" = "true" ]; then
            echo ""
            echo "===================================="
            echo " Update Available!"
            echo "------------------------------------"
            echo " Version Name : $VERSION_NAME"
            echo " Version Code : $VERSION_CODE"
            echo " Release Time : $RELEASE_TIME"
            echo " Status       : AVAILABLE"
            echo "===================================="
            echo ""

            read -p "Would you like to update? (Y/N): " choice

            if [[ "$choice" == "Y" || "$choice" == "y" ]]; then

                ZIP_URL="https://axonagents.netlify.app/updates/latest/${VERSION_NAME}.zip"

                echo "Downloading update package..."

                curl -L "$ZIP_URL" -o "${VERSION_NAME}.zip"

                if [ -f "${VERSION_NAME}.zip" ]; then
                    echo "✅ Update package downloaded successfully!"
                    echo "Saved as: ${VERSION_NAME}.zip"
                else
                    echo "❌ Failed to download update package."
                fi

            else
                echo "Update cancelled."
            fi

        else
            echo "✔ No new updates available."
        fi

    else
        echo "❌ Could not check for updates."
    fi
    ;;

        "restart")
            clear
            exec "$0"
            ;;

        "exit")
            break
            ;;

        "clear")
            clear
            ;;

        *)
            echo -e "${RED}Command not recognized.${RESET} Try \"help\""
            ;;
    esac
done