#
# Copyright 2021 LABOR.digital
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#
# Last modified: 2021.04.19 at 17:38
#

#!/bin/bash

# Perpare variables
NODE_WORKING_DIR=${NODE_WORKING_DIR:-$BITBUCKET_CLONE_DIR}

# Install the dependencies and call the action
cd $NODE_WORKING_DIR
echo "Running npm install in: $NODE_WORKING_DIR"
npm install --no-audit
if [ $? -eq 0 ]; then
    echo Install OK
else
    exit 1
fi

echo "Running npm script..."
npm run "$@"
if [ $? -eq 0 ]; then
    echo OK
else
    exit 1
fi