#!/usr/bin/env bash

SECOND_BRAIN="$HOME/second-brain"
WEEKLY_DIR="$SECOND_BRAIN/weekly"
YEAR=$(date +%G)
WEEK=$(date +%V)
WEEK_FILE="$WEEKLY_DIR/$YEAR-W$WEEK.md"
WINDOW_TITLE="weekly-note"

existing_window=$(aerospace list-windows --all | grep "$WINDOW_TITLE" | head -1 | awk '{print $1}')

if [[ -n "$existing_window" ]]; then
    aerospace focus --window-id "$existing_window"
    exit 0
fi

mkdir -p "$WEEKLY_DIR"

if [[ ! -f "$WEEK_FILE" ]]; then
    # Calculate Monday of current week
    # Get current day of week (1=Monday, 7=Sunday)
    DOW=$(date +%u)
    # Days to subtract to get to Monday
    DAYS_TO_MON=$((DOW - 1))
    
    if [[ -x /bin/date ]]; then
        MON_DATE=$(/bin/date -v-${DAYS_TO_MON}d +"%Y-%m-%d")
        TUE_DATE=$(/bin/date -v-${DAYS_TO_MON}d -v+1d +"%Y-%m-%d")
        WED_DATE=$(/bin/date -v-${DAYS_TO_MON}d -v+2d +"%Y-%m-%d")
        THU_DATE=$(/bin/date -v-${DAYS_TO_MON}d -v+3d +"%Y-%m-%d")
        FRI_DATE=$(/bin/date -v-${DAYS_TO_MON}d -v+4d +"%Y-%m-%d")
        SAT_DATE=$(/bin/date -v-${DAYS_TO_MON}d -v+5d +"%Y-%m-%d")
        SUN_DATE=$(/bin/date -v-${DAYS_TO_MON}d -v+6d +"%Y-%m-%d")
    else
        MON_DATE=$(date -d "monday this week" +"%Y-%m-%d")
        TUE_DATE=$(date -d "tuesday this week" +"%Y-%m-%d")
        WED_DATE=$(date -d "wednesday this week" +"%Y-%m-%d")
        THU_DATE=$(date -d "thursday this week" +"%Y-%m-%d")
        FRI_DATE=$(date -d "friday this week" +"%Y-%m-%d")
        SAT_DATE=$(date -d "saturday this week" +"%Y-%m-%d")
        SUN_DATE=$(date -d "sunday this week" +"%Y-%m-%d")
    fi
    
    cat > "$WEEK_FILE" << EOF
# Week $WEEK ($MON_DATE - $SUN_DATE)

## Hunt Board

> Stars: 1=30min 2=2hr 3=half-day 4=day 5=multi-day | Domains: w=work t=tuimer d=dotfiles p=personal l=learning

### Active

- 

### Backlog

- 

---

## Tasks

- 

## Capture

- 

## Monday | $MON_DATE

- 

## Tuesday | $TUE_DATE

- 

## Wednesday | $WED_DATE

- 

## Thursday | $THU_DATE

- 

## Friday | $FRI_DATE

- 

## Saturday | $SAT_DATE

- 

## Sunday | $SUN_DATE

- 
EOF
fi

kitty --single-instance --title "$WINDOW_TITLE" --directory "$SECOND_BRAIN" nvim "+normal G" "+startinsert!" "$WEEK_FILE"
