/*
 * Copyright 2019 LABOR.digital
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 *
 * Last modified: 2019.11.16 at 12:24
 */

const helpers = require("./helpers");
const childProcess = require("child_process");

// Validate environment variables
const releaseToken = helpers.getEnvVarOrDie("SENTRY_RELEASE_TOKEN");
const organization = helpers.getEnvVarOrDie("SENTRY_ORGANIZATION");
const release = helpers.getEitherOrEnvVar("SENTRY_RELEASE", "BITBUCKET_COMMIT");

// Make the api call
let cmd = "sentry-cli --auth-token \"" + releaseToken + "\" releases -o \"" + organization + "\" finalize \"" + release + "\"";
childProcess.execSync(cmd);
cmd = "sentry-cli --auth-token \"" + releaseToken + "\" releases -o \"" + organization + "\" deploys \"" + release + "\" new -e \"production\"";
childProcess.execSync(cmd);

// Done
console.log("Sentry release " + release + " was prepared successfully!");
process.exit();