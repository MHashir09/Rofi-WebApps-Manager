#!/bin/bash

# ============================================================
#               ROFI WEBAPPS MANAGER                         #
# A rofi-based web app manager for Chromium-based browsers   #
#              Made by MHIA (MHashir09)                      #
# ============================================================

# // --  Default browser binary -- //
# // -- To change, use Modify WebApps --> Migrate WebApps -- //
BROWSER="helium-browser"

# // -- Directory where .desktop files are stored -- //
APPS_DIR="$HOME/.local/share/applications"

# // -- Directory where webapp icons are stored -- //
ICON_DIR="$HOME/.local/share/icons/webapps"

# ============================================
#             HELPER FUNCTIONS               #
# ============================================

# // -- Returns a list of .desktop files that were created by this script  -- //
# -- It identifies them by checking if they contain "$BROWSER --app=" --
get_webapps() {
    grep -rl "$BROWSER --app=" "$APPS_DIR" 2>/dev/null
}

# // -- Reads the Name= field from each webapp's .desktop file -- //
# --  Uses a while loop with IFS= to properly handle spaces in filenames --
get_webapp_names() {
    while IFS= read -r f; do
        grep "^Name=" "$f" | cut -d= -f2
    done < <(get_webapps)
}

# // -- Finds the .desktop file for a given webapp name -- //
# -- Uses grep to search by content rather than filename to handle spaces --
get_file_by_name() {
    local name="$1"
    grep -rl "^Name=$name" "$APPS_DIR" 2>/dev/null | head -1
}

# // -- Sends a desktop notification via dunst  -- //
notify() {
    dunstify "Webapp Manager" "$1"
}

# // -- Prepends https://www. to URLs that don't already have a protocol -- //
# -- e.g. "youtube.com" becomes "https://www.youtube.com" --
# -- Full URLs like "https://www.youtube.com" are left unchanged --
normalize_url() {
    local url="$1"
    if [[ "$url" != http://* && "$url" != https://* ]]; then
        url="https://www.$url"
    fi
    echo "$url"
}

# // -- Validates a URL by sending a HEAD request with curl -- //
# -- Shows a "please wait" notification that gets replaced with the result  --
# -- Returns 1 if the URL is unreachable so the caller can abort --
validate_url() {
    local url="$1"
    local notif_id=9999
    dunstify -r $notif_id "Webapp Manager" "Validating URL, please wait..."
    if ! curl -sL --max-time 5 --head "$url" | grep -q "HTTP/"; then
        dunstify -r $notif_id "Webapp Manager" "Invalid or unreachable URL: $url"
        return 1
    fi
    dunstify -r $notif_id "Webapp Manager" "URL looks good!"
    return 0
}

# // -- Fetches favicon from Google's favicon service -- //
# -- Falls back to a system icon if favicon is not found or empty -- //
fetch_favicon() {
    local url="$1"
    local icon_path="$2"
    curl -sL "https://www.google.com/s2/favicons?domain=$url&sz=128" -o "$icon_path"
    if [ ! -s "$icon_path" ]; then
        notify "Favicon not found, using default icon"
        cp /usr/share/icons/hicolor/48x48/apps/chromium.png "$icon_path" 2>/dev/null || \
        cp /usr/share/pixmaps/chromium.png "$icon_path" 2>/dev/null || \
        rm -f "$icon_path"
    fi
}

# =============================================
#             MAIN FUNCTIONS                  #
# =============================================

# // -- Prompts user for a name and URL, validates the URL,
# fetches the favicon from Google's favicon service,
# and creates a .desktop file that launches the webapp in the browser -- //
summon_webapp() {
    # -- prompt for app name --
    NAME=$(rofi -dmenu -p "  Enter the name of web-app  󰁖  " -lines 0 \
        -theme-str '
            window {
                width: 650px;
                height: 50px;
            }
            mainbox { padding: -1px; }
            inputbar {
                children: [prompt, entry];
                padding: 12px 20px;
            }
            entry {
                expand: true;
                placeholder: "e.g. YouTube";
            }
        ')
    [ -z "$NAME" ] && return

    # -- prompt for URL --
    URL=$(rofi -dmenu -p "  Enter the URL  󰁖  " -lines 0 \
        -theme-str '
            window {
                width: 750px;
                height: 50px;
            }
            mainbox { padding: -1px; }
            inputbar {
                children: [prompt, entry];
                padding: 12px 30px;
            }
            entry {
                expand: true;
                placeholder: "e.g. youtube.com or https://www.youtube.com";
            }
        ')
    [ -z "$URL" ] && return

    # -- normalize and validate the URL before proceeding --
    URL=$(normalize_url "$URL")
    validate_url "$URL" || return

    # -- sanitize name for use as a filename by replacing spaces with dashes --
    FILENAME=$(echo "$NAME" | tr ' ' '-')

    # -- create icon directory and fetch favicon --
    mkdir -p "$ICON_DIR"
    fetch_favicon "$URL" "$ICON_DIR/$FILENAME.png"

    # -- create the .desktop file --
    cat > "$APPS_DIR/$FILENAME.desktop" <<EOF
[Desktop Entry]
Name=$NAME
Exec=$BROWSER --app=$URL --window-decorations=false
Icon=$ICON_DIR/$FILENAME.png
Type=Application
Categories=Network;
EOF
    notify "Webapp '$NAME' created!"
}

# // -- Lists all installed webapps and lets user select one to remove -- //
# -- Deletes both the .desktop file and the icon --
remove_webapp() {
    NAMES=$(get_webapp_names)
    if [ -z "$NAMES" ]; then
        notify "No webapps found"
        return
    fi

    SELECTED=$(echo "$NAMES" | rofi -dmenu -p "  Remove Webapps" \
      -theme-str '
         window {
            width: 260px;
            x-offset: 0;
            y-offset: 0;
         }
        inputbar { children: [prompt]; }
        textbox-prompt-colon { enabled: false; }
        entry { enabled: false; }
        element-text { horizontal-align: 0; }
      ')
    [ -z "$SELECTED" ] && return

    FILE=$(get_file_by_name "$SELECTED")
    FILENAME=$(echo "$SELECTED" | tr ' ' '-')

    # -- remove both the desktop file and its icon --
    rm -f "$FILE"
    rm -f "$ICON_DIR/$FILENAME.png"
    notify "Webapp '$SELECTED' removed!"
}

# // -- Scans for installed Chromium-based browsers and lets user pick one -- //
# // -- Updates all existing webapp .desktop files to use the new browser -- //
# // -- Also permanently updates the BROWSER variable in this script file -- //
migrate_webapps() {
    # -- map of display names to binary names --
    declare -A BROWSERS=(
        ["Google Chrome"]="google-chrome-stable"
        ["Chromium"]="chromium"
        ["Helium Browser"]="helium-browser"
        ["Ungoogled Chromium"]="ungoogled-chromium"
        ["Brave"]="brave"
        ["Brave (brave-browser)"]="brave-browser"
        ["Vivaldi"]="vivaldi"
        ["Microsoft Edge"]="microsoft-edge"
    )

    DISPLAY_NAMES=()
    BINARIES=()

    # -- only show browsers that are actually installed --
    for BNAME in "${!BROWSERS[@]}"; do
        BINARY="${BROWSERS[$BNAME]}"
        if command -v "$BINARY" &>/dev/null; then
            DISPLAY_NAMES+=("$BNAME")
            BINARIES+=("$BINARY")
        fi
    done

    if [ ${#DISPLAY_NAMES[@]} -eq 0 ]; then
        notify "No supported Chromium browsers found installed"
        return
    fi

    # -- show only display names to rofi, not binaries --
    SELECTED=$(printf "%s\n" "${DISPLAY_NAMES[@]}" | rofi -dmenu -i -p "   Select Browser" \
        -theme-str '
            window {
                width: 280px;
                x-offset: 0;
                y-offset: 0;
            }
            inputbar { children: [prompt]; }
            textbox-prompt-colon { enabled: false; }
            entry { enabled: false; }
        ')
    [ -z "$SELECTED" ] && return

    # -- find the binary that matches the selected display name --
    NEW_BINARY=""
    for i in "${!DISPLAY_NAMES[@]}"; do
        if [ "${DISPLAY_NAMES[$i]}" = "$SELECTED" ]; then
            NEW_BINARY="${BINARIES[$i]}"
            break
        fi
    done

    # -- update all webapp .desktop files to use the new browser --
    COUNT=0
    while IFS= read -r f; do
        sed -i "s|Exec=$BROWSER --app=|Exec=$NEW_BINARY --app=|g" "$f"
        COUNT=$((COUNT + 1))
    done < <(grep -rl "$BROWSER --app=" "$APPS_DIR" 2>/dev/null)

    # -- permanently update the BROWSER variable in this script file  --
    # -- $0 refers to the script itself --
    sed -i "s|^BROWSER=.*|BROWSER=\"$NEW_BINARY\"|" "$0"

    BROWSER="$NEW_BINARY"
    notify "Migrated $COUNT webapp(s) to $SELECTED!"
}

# // -- Lets user change the name, URL, or browser of existing webapps -- //
modify_webapp() {
    ACTION=$(printf "Change Name\nChange URL\nMigrate WebApps" | rofi -dmenu -i -p "   Modify WebApps" \
    -theme-str '
        window {
            width: 280px;
            x-offset: 0;
            y-offset: 0;
        }
        inputbar { children: [prompt]; }
        textbox-prompt-colon { enabled: false; }
        entry { enabled: false; }
    ')
    [ -z "$ACTION" ] && return

    # -- migrate is handled separately since it doesnt need a specific webapp selected --
    if [ "$ACTION" = "Migrate WebApps" ]; then
        migrate_webapps
        return
    fi

    NAMES=$(get_webapp_names)
    if [ -z "$NAMES" ]; then
        notify "No webapps found"
        return
    fi

    # -- let user pick which webapp to modify --
    SELECTED=$(echo "$NAMES" | rofi -dmenu -p "   Select Webapp" \
    -theme-str '
        window {
            width: 280px;
            x-offset: 0;
            y-offset: 0;
        }
        inputbar { children: [prompt]; }
        textbox-prompt-colon { enabled: false; }
        entry { enabled: false; }
    ')
    [ -z "$SELECTED" ] && return

    FILE=$(get_file_by_name "$SELECTED")
    FILENAME=$(echo "$SELECTED" | tr ' ' '-')

    # // -- Changes Name of webapp -- //
    if [ "$ACTION" = "Change Name" ]; then
        NEW_NAME=$(rofi -dmenu -p "  Enter new name of WebApp  󰁖  " -lines 0 \
            -theme-str '
              window {
                width: 750px;
                height: 50px;
              }
              mainbox { padding: -1px; }
              inputbar {
                children: [prompt, entry];
                padding: 12px 30px;
              }
             entry {
                expand: true;
                placeholder: "e.g. YouTube";
             }
           ')
        [ -z "$NEW_NAME" ] && return
        NEW_FILENAME=$(echo "$NEW_NAME" | tr ' ' '-')

        # -- update the Name field in the desktop file --
        sed -i "s/^Name=.*/Name=$NEW_NAME/" "$FILE"
        # -- update the Icon path to match the new filename --
        sed -i "s|Icon=$ICON_DIR/$FILENAME.png|Icon=$ICON_DIR/$NEW_FILENAME.png|" "$FILE"
        # -- rename both the desktop file and icon to match the new name --
        mv "$FILE" "$APPS_DIR/$NEW_FILENAME.desktop"
        mv "$ICON_DIR/$FILENAME.png" "$ICON_DIR/$NEW_FILENAME.png" 2>/dev/null
        notify "Renamed to '$NEW_NAME'!"

    # // -- changes URL of the webapp -- //
    elif [ "$ACTION" = "Change URL" ]; then
        NEW_URL=$(rofi -dmenu -p "  Enter new URL of WebApp  󰁖  " -lines 0 \
           -theme-str '
              window {
                width: 750px;
                height: 50px;
            }
              mainbox { padding: -1px; }
              inputbar {
                children: [prompt, entry];
                padding: 12px 30px;
            }
            entry {
                expand: true;
                placeholder: "e.g. youtube.com or https://www.youtube.com";
            }
           ')
        [ -z "$NEW_URL" ] && return
        NEW_URL=$(normalize_url "$NEW_URL")
        validate_url "$NEW_URL" || return

        # -- update the Exec line in the desktop file with the new URL --
        sed -i "s|Exec=$BROWSER --app=.* --window-decorations=false|Exec=$BROWSER --app=$NEW_URL --window-decorations=false|" "$FILE"
        # -- fetch new favicon for the updated URL --
        fetch_favicon "$NEW_URL" "$ICON_DIR/$FILENAME.png"
        notify "URL updated for '$SELECTED'!"
    fi
}

# ==================================
#          ENTRY POINT             #
# ==================================

# // -- Main menu — shows three options and routes to the appropriate function -- //
CHOICE=$(printf "Summon Webapp\nRemove Webapp\nModify Webapp" | rofi -dmenu -i -p "    Web-Apps-Man " \
    -theme-str '
        window {
            width: 280px;
            x-offset: 0;
            y-offset: 0;
        }
        inputbar { children: [prompt]; }
        textbox-prompt-colon { enabled: false; }
        entry { enabled: false; }
    ')

# // -- Calls appropriate functions based on users choice -- //
case "$CHOICE" in
    "Summon Webapp") summon_webapp ;;
    "Remove Webapp") remove_webapp ;;
    "Modify Webapp") modify_webapp ;;
esac

# ========================================================================================= #
