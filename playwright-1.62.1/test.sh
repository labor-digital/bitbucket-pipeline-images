#!/bin/bash

#
# Copyright 2026 LABOR.digital
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
# Last modified: 2026.06.24 at 11:06
#

# Prepare variables
TEST_ROOT_DIR=${TEST_ROOT_DIR:-$BITBUCKET_CLONE_DIR}
TEST_BASE_URL=${TEST_BASE_URL:-"https://host.docker.internal"}

# Install hosts if requested
if [ "$TEST_HOST_IP" != "" ] && [ "$TEST_HOST_NAME" != "" ]; then
  echo "${TEST_HOST_IP} ${TEST_HOST_NAME}" >> /etc/hosts
fi

# Install the dependencies and call the action
cd /app
echo "Running test..."
npm run test
if [ $? -eq 0 ]; then
    echo OK
else
    exit 1
fi