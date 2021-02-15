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
 * Last modified: 2019.11.16 at 12:23
 */

module.exports = {
	kill: (message) => {
		console.log("--------------------------------------");
		console.log("ERROR!");
		console.log("--------------------------------------");
		console.log(message);
		process.exit(1);
	},
	getEitherOrEnvVar: (either, or) => {
		if (typeof process.env[either] === "undefined") {
			if (typeof process.env[or] === "undefined") this.kill("Missing " + either + " or " + or + " environment variable!");
			return process.env[or];
		}
		return process.env[either];
	},
	getEnvVarOrCall: (name, callback) => {
		if (typeof process.env[name] === "undefined") return callback();
		return process.env[name];
	},
	getEnvVarOrDie: (name) => {
		if (typeof process.env[name] === "undefined") this.kill("Missing " + name + " environment variable!");
		return process.env[name];
	}
};