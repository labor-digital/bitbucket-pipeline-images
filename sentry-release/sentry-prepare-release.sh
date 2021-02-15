#!/bin/bash

node /opt/sentryjs/sentry-prepare-release.js
if [ $? -eq 0 ]; then
    echo OK
else
    exit 1
fi