#!/bin/bash
set -o errexit
set -o nounset
set -o pipefail

#-------------------------------------------------------------------------------
# to ensure the script actually runs inside its own folder
MY_PATH="`dirname \"$0\"`"              # relative
MY_PATH="`( cd \"$MY_PATH\" && pwd )`"  # absolutized and normalized
if [ -z "$MY_PATH" ] ; then
  # Error. for some reason, the path is not accessible
  # to the script (e.g. permissions re-evaled after suid)
  exit 1 # Fail
fi

BINARY_DIR=$1
coproc $BINARY_DIR/helloworld_server
SERVER_PID=$!

expected="$MY_PATH/expected.txt"
observed="output.txt"
\rm -f $observed

curl --request GET \
  --url http://localhost:8080 \
  -o $observed
if cmp -s "$expected" "$observed"; then
  echo "All good"
else
  echo "Unexpected response from server"
  exit 1
fi
\rm -f $observed

kill $SERVER_PID

exit 0