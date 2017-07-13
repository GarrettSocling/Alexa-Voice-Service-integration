#!/bin/bash -e

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
PARENT="$( dirname "$DIR" )"
source "$PARENT/config"

if [ -f "$AVS_RESP_FILE" ]; then
	mpg123 "$AVS_RESP_FILE"
	rm "$AVS_RESP_FILE"
	echo "OK"
	exit 0
else
	echo "No Alexa playback file found."
	exit 1
fi