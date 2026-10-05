#!/bin/bash
/opt/npm-login.sh
/opt/npm-run-script-without-login.sh "$@"
if [ $? -eq 0 ]; then
    echo OK
else
    exit 1
fi