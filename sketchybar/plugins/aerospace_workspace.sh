#!/bin/bash

source "$CONFIG_DIR/colors.sh"

# Inline icon mapping function - avoid shell overhead
get_app_icon() {
    case "$1" in
        "Live") echo ":ableton:" ;;
        "Adobe Bridge"*) echo ":adobe_bridge:" ;;
        "Affinity Designer") echo ":affinity_designer:" ;;
        "Affinity Designer 2") echo ":affinity_designer_2:" ;;
        "Affinity Photo") echo ":affinity_photo:" ;;
        "Affinity Photo 2") echo ":affinity_photo_2:" ;;
        "Affinity Publisher") echo ":affinity_publisher:" ;;
        "Affinity Publisher 2") echo ":affinity_publisher_2:" ;;
        "Airmail") echo ":airmail:" ;;
        "Alacritty") echo ":alacritty:" ;;
        "Alfred") echo ":alfred:" ;;
        "Android Messages") echo ":android_messages:" ;;
        "Android Studio") echo ":android_studio:" ;;
        "Anytype") echo ":anytype:" ;;
        "App Eraser") echo ":app_eraser:" ;;
        "App Store") echo ":app_store:" ;;
        "Arc") echo ":arc:" ;;
        "Atom") echo ":atom:" ;;
        "Audacity") echo ":audacity:" ;;
        "Bambu Studio") echo ":bambu_studio:" ;;
        "MoneyMoney") echo ":bank:" ;;
        "Battle.net") echo ":battle_net:" ;;
        "Bear") echo ":bear:" ;;
        "BetterTouchTool") echo ":bettertouchtool:" ;;
        "Bilibili"|"哔哩哔哩") echo ":bilibili:" ;;
        "Bitwarden") echo ":bit_warden:" ;;
        "Blender") echo ":blender:" ;;
        "BluOS Controller") echo ":bluos_controller:" ;;
        "Calibre") echo ":book:" ;;
        "Brave Browser") echo ":brave_browser:" ;;
        "Calculator"|"Calculette") echo ":calculator:" ;;
        "Calendar"|"日历"|"Fantastical"|"Cron"|"Amie"|"Calendrier"|"Notion Calendar") echo ":calendar:" ;;
        "Caprine") echo ":caprine:" ;;
        "Citrix Workspace"|"Citrix Viewer") echo ":citrix:" ;;
        "ClickUp") echo ":click_up:" ;;
        "Code"|"Code - Insiders") echo ":code:" ;;
        "Color Picker"|"数码测色计") echo ":color_picker:" ;;
        "CotEditor") echo ":coteditor:" ;;
        "Creative Cloud") echo ":creative_cloud:" ;;
        "Cypress") echo ":cypress:" ;;
        "DataGrip") echo ":datagrip:" ;;
        "DataSpell") echo ":dataspell:" ;;
        "DaVinci Resolve") echo ":davinciresolve:" ;;
        "Default") echo ":default:" ;;
        "CleanMyMac X") echo ":desktop:" ;;
        "DEVONthink 3") echo ":devonthink3:" ;;
        "DingTalk"|"钉钉"|"阿里钉") echo ":dingtalk:" ;;
        "Discord"|"Discord Canary"|"Discord PTB") echo ":discord:" ;;
        "Docker"|"Docker Desktop") echo ":docker:" ;;
        "GrandTotal"|"Receipts") echo ":dollar:" ;;
        "Double Commander") echo ":doublecmd:" ;;
        "Drafts") echo ":drafts:" ;;
        "Dropbox") echo ":dropbox:" ;;
        "Element") echo ":element:" ;;
        "Emacs") echo ":emacs:" ;;
        "Evernote Legacy") echo ":evernote_legacy:" ;;
        "FaceTime"|"FaceTime 通话") echo ":face_time:" ;;
        "Figma") echo ":figma:" ;;
        "Final Cut Pro") echo ":final_cut_pro:" ;;
        "Finder"|"访达") echo ":finder:" ;;
        "Firefox") echo ":firefox:" ;;
        "Firefox Developer Edition"|"Firefox Nightly") echo ":firefox_developer_edition:" ;;
        "Folx") echo ":folx:" ;;
        "Fusion") echo ":fusion:" ;;
        "System Preferences"|"System Settings"|"系统设置"|"Réglages Système") echo ":gear:" ;;
        "GitHub Desktop") echo ":git_hub:" ;;
        "Godot") echo ":godot:" ;;
        "GoLand") echo ":goland:" ;;
        "Chromium"|"Google Chrome"|"Google Chrome Canary") echo ":google_chrome:" ;;
        "Grammarly Editor") echo ":grammarly:" ;;
        "Home Assistant") echo ":home_assistant:" ;;
        "Hyper") echo ":hyper:" ;;
        "IntelliJ IDEA") echo ":idea:" ;;
        "Inkdrop") echo ":inkdrop:" ;;
        "Inkscape") echo ":inkscape:" ;;
        "Insomnia") echo ":insomnia:" ;;
        "Iris") echo ":iris:" ;;
        "iTerm"|"iTerm2") echo ":iterm:" ;;
        "Jellyfin Media Player") echo ":jellyfin:" ;;
        "Joplin") echo ":joplin:" ;;
        "카카오톡"|"KakaoTalk") echo ":kakaotalk:" ;;
        "Kakoune") echo ":kakoune:" ;;
        "KeePassXC") echo ":kee_pass_x_c:" ;;
        "Keyboard Maestro") echo ":keyboard_maestro:" ;;
        "Keynote"|"Keynote 讲演") echo ":keynote:" ;;
        "kitty") echo ":kitty:" ;;
        "League of Legends") echo ":league_of_legends:" ;;
        "LibreWolf") echo ":libre_wolf:" ;;
        "Adobe Lightroom") echo ":lightroom:" ;;
        "Lightroom Classic") echo ":lightroomclassic:" ;;
        "LINE") echo ":line:" ;;
        "Linear") echo ":linear:" ;;
        "LM Studio") echo ":lm_studio:" ;;
        "LocalSend") echo ":localsend:" ;;
        "Logic Pro") echo ":logicpro:" ;;
        "Logseq") echo ":logseq:" ;;
        "Canary Mail"|"HEY"|"Mail"|"Mailspring"|"MailMate"|"Superhuman"|"Spark"|"邮件") echo ":mail:" ;;
        "MAMP"|"MAMP PRO") echo ":mamp:" ;;
        "Maps"|"Google Maps") echo ":maps:" ;;
        "Matlab") echo ":matlab:" ;;
        "Mattermost") echo ":mattermost:" ;;
        "Messages"|"信息"|"Nachrichten") echo ":messages:" ;;
        "Messenger") echo ":messenger:" ;;
        "Microsoft Edge") echo ":microsoft_edge:" ;;
        "Microsoft Excel") echo ":microsoft_excel:" ;;
        "Microsoft Outlook") echo ":microsoft_outlook:" ;;
        "Microsoft PowerPoint") echo ":microsoft_power_point:" ;;
        "Microsoft Remote Desktop") echo ":microsoft_remote_desktop:" ;;
        "Microsoft Teams"|"Microsoft Teams (work or school)") echo ":microsoft_teams:" ;;
        "Microsoft Word") echo ":microsoft_word:" ;;
        "Min") echo ":min_browser:" ;;
        "Miro") echo ":miro:" ;;
        "MongoDB Compass"*) echo ":mongodb:" ;;
        "mpv") echo ":mpv:" ;;
        "Mullvad Browser") echo ":mullvad_browser:" ;;
        "Music"|"音乐"|"Musique") echo ":music:" ;;
        "Neovide"|"neovide") echo ":neovide:" ;;
        "Neovim"|"neovim"|"nvim") echo ":neovim:" ;;
        "网易云音乐") echo ":netease_music:" ;;
        "Noodl"|"Noodl Editor") echo ":noodl:" ;;
        "NordVPN") echo ":nord_vpn:" ;;
        "Notability") echo ":notability:" ;;
        "Notes"|"备忘录") echo ":notes:" ;;
        "Notion") echo ":notion:" ;;
        "Nova") echo ":nova:" ;;
        "Numbers"|"Numbers 表格") echo ":numbers:" ;;
        "Obsidian") echo ":obsidian:" ;;
        "OBS") echo ":obsstudio:" ;;
        "OmniFocus") echo ":omni_focus:" ;;
        "1Password") echo ":one_password:" ;;
        "ChatGPT") echo ":openai:" ;;
        "OpenVPN Connect") echo ":openvpn_connect:" ;;
        "Opera") echo ":opera:" ;;
        "OrcaSlicer") echo ":orcaslicer:" ;;
        "Orion"|"Orion RC") echo ":orion:" ;;
        "Pages"|"Pages 文稿") echo ":pages:" ;;
        "Parallels Desktop") echo ":parallels:" ;;
        "Parsec") echo ":parsec:" ;;
        "Preview"|"预览"|"Skim"|"zathura"|"Aperçu") echo ":pdf:" ;;
        "PDF Expert") echo ":pdf_expert:" ;;
        "Adobe Photoshop"*) echo ":photoshop:" ;;
        "PhpStorm") echo ":php_storm:" ;;
        "Pi-hole Remote") echo ":pihole:" ;;
        "Pine") echo ":pine:" ;;
        "Podcasts"|"播客") echo ":podcasts:" ;;
        "PomoDone App") echo ":pomodone:" ;;
        "Postman") echo ":postman:" ;;
        "Proton Mail"|"Proton Mail Bridge") echo ":proton_mail:" ;;
        "PrusaSlicer"|"SuperSlicer") echo ":prusaslicer:" ;;
        "PyCharm") echo ":pycharm:" ;;
        "QQ") echo ":qq:" ;;
        "QQ音乐"|"QQMusic") echo ":qqmusic:" ;;
        "Quantumult X") echo ":quantumult_x:" ;;

        "Raindrop.io") echo ":raindrop_io:" ;;
        "Reeder") echo ":reeder5:" ;;
        "Reminders"|"提醒事项"|"Rappels") echo ":reminders:" ;;
        "Replit") echo ":replit:" ;;
        "Rider"|"JetBrains Rider") echo ":rider:" ;;
        "Safari"|"Safari浏览器"|"Safari Technology Preview") echo ":safari:" ;;
        "Sequel Ace") echo ":sequel_ace:" ;;
        "Sequel Pro") echo ":sequel_pro:" ;;
        "Setapp") echo ":setapp:" ;;
        "SF Symbols") echo ":sf_symbols:" ;;
        "Signal") echo ":signal:" ;;
        "Sketch") echo ":sketch:" ;;
        "Skype") echo ":skype:" ;;
        "Slack") echo ":slack:" ;;
        "Spark Desktop") echo ":spark:" ;;
        "Spotify") echo ":spotify:" ;;
        "YouTube Music") echo ":music:" ;;
        "Spotlight") echo ":spotlight:" ;;
        "Sublime Text") echo ":sublime_text:" ;;
        "Tana") echo ":tana:" ;;
        "TeamSpeak 3") echo ":team_speak:" ;;
        "Telegram") echo ":telegram:" ;;
        "Terminal"|"终端") echo ":terminal:" ;;
        "Typora") echo ":text:" ;;
        "Microsoft To Do"|"Things") echo ":things:" ;;
        "Thunderbird") echo ":thunderbird:" ;;
        "TickTick") echo ":tick_tick:" ;;
        "TIDAL") echo ":tidal:" ;;
        "Tiny RDM") echo ":tinyrdm:" ;;
        "Todoist") echo ":todoist:" ;;
        "Toggl Track") echo ":toggl_track:" ;;
        "Tor Browser") echo ":tor_browser:" ;;
        "Tower") echo ":tower:" ;;
        "Transmit") echo ":transmit:" ;;
        "Trello") echo ":trello:" ;;
        "Tweetbot"|"Twitter") echo ":twitter:" ;;
        "MacVim"|"Vim"|"VimR") echo ":vim:" ;;
        "Vivaldi") echo ":vivaldi:" ;;
        "VLC") echo ":vlc:" ;;
        "VMware Fusion") echo ":vmware_fusion:" ;;
        "VSCodium") echo ":vscodium:" ;;
        "Warp") echo ":warp:" ;;
        "WebStorm") echo ":web_storm:" ;;
        "微信"|"WeChat") echo ":wechat:" ;;
        "企业微信"|"WeCom") echo ":wecom:" ;;
        "WezTerm") echo ":wezterm:" ;;
        "WhatsApp"|"‎WhatsApp") echo ":whats_app:" ;;
        "Xcode") echo ":xcode:" ;;
        "Яндекс Музыка") echo ":yandex_music:" ;;
        "Yuque"|"语雀") echo ":yuque:" ;;
        "Zed") echo ":zed:" ;;
        "Zeplin") echo ":zeplin:" ;;
        "zoom.us") echo ":zoom:" ;;
        "Zotero") echo ":zotero:" ;;
        "Zulip") echo ":zulip:" ;;
        *) echo ":default:" ;;
    esac
}

if [ "$SENDER" = "aerospace_workspace_change" ]; then
    # Get current focused workspace
    FOCUSED_WORKSPACE=$(aerospace list-workspaces --focused 2>/dev/null | head -1 | xargs)
    
    # Skip redundant updates - this is the biggest performance gain
    LAST_WORKSPACE_FILE="/tmp/sketchybar_last_workspace"
    if [ -f "$LAST_WORKSPACE_FILE" ] && [ "$(cat "$LAST_WORKSPACE_FILE")" = "$FOCUSED_WORKSPACE" ]; then
        exit 0  # No change needed
    fi
    echo "$FOCUSED_WORKSPACE" > "$LAST_WORKSPACE_FILE"
    
    if [ -n "$FOCUSED_WORKSPACE" ]; then
        # Get app list for focused workspace first (avoid doing this if workspace unchanged)
        apps=$(aerospace list-windows --workspace "$FOCUSED_WORKSPACE" --format "%{app-name}" 2>/dev/null)
        
        # Build icon strip using inline function (no external shell calls)
        icon_strip=" "
        if [ -n "$apps" ]; then
            while IFS= read -r app; do
                if [ -n "$app" ] && [ "$app" != "Finder" ] && [ "$app" != "访达" ]; then
                    icon=$(get_app_icon "$app")
                    icon_strip="$icon_strip$icon"
                fi
            done <<< "$apps"
        else
            icon_strip=" —"
        fi
        
        # Build single sketchybar command for all highlights + icon update
        SKETCHYBAR_CMD="sketchybar"
        for workspace in 1 2 3 4 5 6 7 8 9 10; do
            if [ "$workspace" = "$FOCUSED_WORKSPACE" ]; then
                SKETCHYBAR_CMD="$SKETCHYBAR_CMD --set space.$workspace icon.highlight=true label.highlight=true background.border_color=$GREY label=\"$icon_strip\""
            else
                SKETCHYBAR_CMD="$SKETCHYBAR_CMD --set space.$workspace icon.highlight=false label.highlight=false background.border_color=$BACKGROUND_2"
            fi
        done
        
        # Execute single command for all highlights + icon update
        eval "$SKETCHYBAR_CMD" 2>/dev/null
    fi

elif [ "$SENDER" = "mouse.clicked" ]; then
    # Handle workspace clicks - also update the last workspace file
    WORKSPACE_ID=${NAME#*.}
    echo "$WORKSPACE_ID" > "/tmp/sketchybar_last_workspace"
    aerospace workspace "$WORKSPACE_ID"

fi