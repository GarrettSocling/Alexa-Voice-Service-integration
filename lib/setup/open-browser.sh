#!/bin/bash

TIMEOUT="10"
MSG="Redirecting to pi-top account page...\nThis may take a few moments."
ENDPOINT="https://pi-top.com/account"

wait_pid() {
    i=0
    limit=10
    while [ $i -le $limit ] && [ -e /proc/"$PID" ]; do
        sleep .5
        i=$((i + 1))
    done
}

force_kill() {
    wait_pid

    if kill -0 "$PID" &> /dev/null; then
        kill -KILL "$PID"
        sleep 1
        if ! kill -0 "$PID" &> /dev/null; then
            printf '%s\n' "Process timed out, and was terminated by SIGKILL."
            exit 2
        else
            printf '%s\n' "Process timed out, but can't be terminated (SIGKILL ineffective)."
            exit 1
        fi
    fi
}

timeout() {
    sleep "$TIMEOUT"
    kill -TERM "$PID" &> /dev/null
    force_kill
}


echo -e "$MSG"
zenity --info --text="$MSG" &
PID=$!
timeout &
x-www-browser "$ENDPOINT" &>/dev/null &