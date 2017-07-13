#!/bin/bash -e

if [ "$EUID" -ne 0 ]; then
    echo "Please run 'sudo $0'"
  exit
fi

MY_PT_USERNAME=""
MY_PT_PASSWORD=""


if [[ "$MY_PT_USERNAME" == "" ]]; then
    read -p "Enter your pi-top account username: " MY_PT_USERNAME
fi

if [[ "$MY_PT_PASSWORD" == "" ]]; then
    stty -echo
    printf "Enter your pi-top account password: "
    read MY_PT_PASSWORD
    stty echo
    printf "\n"
fi



setup() {
    PT_RESP=$(pt-avs pt-access-token "$MY_PT_USERNAME" "$MY_PT_PASSWORD")
    PT_USER_ID=$(echo "$PT_RESP" | grep "USER ID" | awk '{print $NF}')
    PT_ACCESS_TOKEN=$(echo "$PT_RESP" | grep "ACCESS TOKEN" | awk '{print $NF}')

    AVS_RESP=$(pt-avs avs-access-token -u "$PT_USER_ID" -t "$PT_ACCESS_TOKEN")

    if grep "\nOK$" <<< "$AVS_RESP"; then
        echo "Unable to get AVS access token."
        echo "Response:"
        echo "$AVS_RESP"
        exit 1
    else
        AVS_ACCESS_TOKEN=$(echo "$AVS_RESP" | head -n 1)
    fi
}

run() {
    echo "Start recording..."
    pt-avs record start
    sleep 5
    echo "Stop recording..."
    RECORD_STOP_RESP=$(pt-avs record stop)
    if grep "\nOK$" <<< "$RECORD_STOP_RESP"; then
        echo "Unable to stop recording."
        echo "Response:"
        echo "$RECORD_STOP_RESP"
        exit 1
    fi

    echo "Uploading..."
    pt-avs upload -t "$AVS_ACCESS_TOKEN"

    echo "Playing back response..."
    pt-avs playback
}


echo "Running setup..."
setup

run
