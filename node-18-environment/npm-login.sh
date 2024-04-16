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

# Prepare environment variables
echo "Checking environment variables..."
NPM_REGISTRY_URL=${NPM_REGISTRY_URL:-$NPM_DEFAULT_REGISTRY_URL}
NPM_REGISTRY_EMAIL=${NPM_REGISTRY_EMAIL:-$NPM_DEFAULT_REGISTRY_EMAIL}
NPM_REGISTRY_USER=${NPM_REGISTRY_USER:-$NPM_DEFAULT_REGISTRY_USER}
NPM_REGISTRY_PW=${NPM_REGISTRY_PW:-$NPM_DEFAULT_REGISTRY_PW}

# Login to our npm repository
echo "Writing .npmrc file..."
npm logout
npm set registry https://$NPM_REGISTRY_URL
npm-cli-login -u $NPM_REGISTRY_USER -p $NPM_REGISTRY_PW -r https://$NPM_REGISTRY_URL -e $NPM_REGISTRY_EMAIL --quotes