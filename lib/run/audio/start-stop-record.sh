#!/bin/bash -e

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
PARENT="$( dirname "$DIR" )"
source "$PARENT/config"

PID_FILE="/var/run/pt-pulse-record.pid"
if [[ -f "$PID_FILE" ]]; then
    PID=$(cat $PID_FILE 2>/dev/null)
fi
TIMEOUT="${TIMEOUT:-15}"
PULSE_RECORD_SCRIPT="$DIR/helper/pt-pulse-record.py"

# INTERNAL FUNCTIONS
ok() {
    echo "OK"
}

cleanup() {
    if [ -f "$AVS_REQ_FILE" ]; then
        sudo rm -f "$AVS_REQ_FILE"
    fi
}

timeout() {
    sleep "$TIMEOUT"
    stop_recording
}

stop_recording() {
    kill -TERM "$PID" &> /dev/null
    force_kill
}

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


# EXTERNAL FUNCTIONS
start() {
    if kill -0 "$PID" &> /dev/null; then
        echo "Already capturing audio"
        return 1
    else
        cleanup
        $PULSE_RECORD_SCRIPT & &> /dev/null
        export PID=$!
        echo "$PID" > $PID_FILE
        ok
        timeout &
        return 0
    fi
}

stop() {
    if kill -0 "$PID" &> /dev/null; then
        stop_recording
    else
        echo "Not currently recording"
    fi
    ok
}

"$@"
