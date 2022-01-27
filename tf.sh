#!/bin/sh

# testflight control script.

echo "testflight control"

if $STAGING; then
    ./asoc-zeek -i "$INTF" -o "$ORG_ID" -s &
else
    ./asoc-zeek -i "$INTF" -o "$ORG_ID" &
fi
pid=$!

echo "running flightsim"
flightsim run

# asoc-zeek configures Zeek to send data to the backend every 30 seconds.  Give Zeek some
# time to catch up, just in case.
sleep_int=90
echo "sleeping for $sleep_int seconds"
sleep $sleep_int

# Kill asoc-zeek, which will kill Zeek and cleanup.  As such, give it a few seconds.
kill $pid
sleep 10

echo "done"
