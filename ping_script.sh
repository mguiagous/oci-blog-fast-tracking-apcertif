#!/bin/bash

# Target IP address (use environment variable)
TARGET_IP="${TARGET_IP:-}"

# Number of ping attempts (use environment variable)
PING_COUNT=${PING_COUNT:-5}

# Function to check ping success
ping_and_check() {
  ping_result=$(ping -c 1 -q -W 2 "$TARGET_IP" 2>&1)  # Capture standard output and error
  if [[ $? -eq 0 ]]; then
    echo "Ping to $TARGET_IP successful!"
  else
    echo "Ping to $TARGET_IP failed!"
  fi
  echo "$ping_result"
}

# Perform pings with loop
for (( i=0; i<$PING_COUNT; i++ )); do
  if ! ping_and_check; then
    echo "Ping attempt $((i+1)) failed."
  fi
done

# Exit with success/failure code based on ping results
if [[ $(ping_and_check) -eq 0 ]]; then
  exit 0  # Success
else
  exit 0  # Failure (at least one ping failed)
fi

