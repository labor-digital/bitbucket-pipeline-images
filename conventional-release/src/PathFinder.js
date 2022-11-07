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
 * Last modified: 2019.03.15 at 16:42
 */
const path = require("path");
const fs = require("fs");
const os = require("os");

module.exports = class PathFinder {
	/**
	 * Tries to find the most sensible directories to get release related objects
	 * like the .git directory or the package.json in.
	 *
	 * Option 1:
	 * There is a package.json / composer.json in the directory 'srcDir' which we got as param -> use this directory
	 *
	 * Option 2:
	 * There is a package.json / composer.json in the current directory -> use this directory
	 *
	 * Option 3:
	 * Check if there is an src directory inside the current directory and look if we find the files there
	 *
	 * Option 4:
	 * Traverse the path upwards until we find a package.json / composer.json file
	 *
	 * Option 5:
	 * If no file was found in option 2, check if we can find a package json in a current app's
	 * root / app / src directories
	 *
	 * If we found a directory traverse the path upwards to find the closest .git directory
	 *
	 * @param {boolean} [ignoreMissingGit] If set to true there will be no error thrown if result.git directory is empty
	 * @returns {{cwd: string, git: string|null, appApp: string|null, appSrc: string|null, packageJson: string|null, composerJson: string|null, changelogMd: string|null, config: string|null, appRoot: string|null}}
	 */
	static findReleaseElements(ignoreMissingGit, srcDir = null) {
		const result = {
			cwd: PathFinder.unifyPath(process.cwd()),
			appRoot: null,
			appApp: null,
			appSrc: null,
			config: null,
			git: null,
			packageJson: null,
			composerJson: null,
			changelogMd: null
		};

		// Try to find app directories
		PathFinder.traversePathUpwards(result.cwd, (directory) => {
			// Find root directory (probably only local, where the LaborApp.json lives)
			let testFile = path.join(directory, "LaborApp.json");
			if (!fs.existsSync(testFile)) return false;
			result.appRoot = PathFinder.unifyPath(directory);

			// Try to find the app directory
			testFile = path.join(directory, "app");
			if (fs.existsSync(testFile)) result.appApp = PathFinder.unifyPath(testFile);
			else return true;

			// Try to find the src inside the app directory
			testFile = path.join(result.appApp, "src");
			if (fs.existsSync(testFile)) result.appSrc = PathFinder.unifyPath(testFile);
		});

		// Prepare internal helpers
		const findConfigFiles = function (directory) {
			directory = PathFinder.unifyPath(directory);
			if (result.packageJson === null) {
				const testFile = path.join(directory, "package.json");
				if (fs.existsSync(testFile)) result.packageJson = testFile;
			}
			if (result.composerJson === null) {
				const testFile = path.join(directory, "composer.json");
				if (fs.existsSync(testFile)) result.composerJson = testFile;
			}
			if (result.changelogMd === null) {
				["CHANGELOG.md", "CHANGELOG.MD", "changelog.md", "Changelog.md"].forEach(file => {
					if (result.changelogMd !== null) return;
					const testFile = path.join(directory, file);
					if (fs.existsSync(testFile)) result.changelogMd = testFile;
				});
			}
			if (result.config === null && (result.packageJson !== null || result.composerJson !== null))
				result.config = directory;
		};

		// Option 1:
		if (srcDir) {
			findConfigFiles(path.join(result.cwd, srcDir));
		}

		// Option 2:
		if (result.config === null) {
			findConfigFiles(result.cwd);
		}

		// Option 3:
		if (result.config === null) {
			const srcPath = path.join(result.cwd, "src");
			if(fs.existsSync(srcPath)) findConfigFiles(srcPath);
		}

		// Option 4:
		if (result.config === null) {
			PathFinder.traversePathUpwards(result.cwd, (directory) => {
				findConfigFiles(directory);
				if (result.packageJson !== null || result.composerJson !== null) return true;
			});
		}

		// Option 5:
		if (result.config === null || result.packageJson === null && result.composerJson === null) {
			[result.appRoot, result.appApp, result.appSrc].forEach(testDir => {
				if (testDir === null || result.packageJson !== null || result.composerJson !== null) return;
				findConfigFiles(testDir);
			});
		}

		// Skip looking for other stuff, if we don't have a config...
		if(result.config === null)
			throw new Error("Did not find a package.json or composer.json");

		// Find git
		if (fs.existsSync(path.join(result.config, ".git"))) {
			// Local directory...
			result.git = result.config;
		} else {
			// Traverse upwards...
			PathFinder.traversePathUpwards(result.config, (directory) => {
				if (fs.existsSync(path.join(directory, ".git"))) {
					result.git = directory;
					return true;
				}
			});
		}

		// Make sure we have a changelog file
		if(result.changelogMd === null) result.changelogMd = path.join(
			(result.git === null ? result.config : result.git), "CHANGELOG.md");

		// Validate if we got git
		if(ignoreMissingGit !== true && result.git === null)
			throw new Error("Did not find a git directory to work with");

		// Done
		return result;
	}

	/**
	 * Resolves the path and unifies its separators and appends a tailing slash
	 * @param {string} pathName
	 * @returns {string}
	 */
	static unifyPath(pathName) {
		if(os.platform() !== "win32" && os.platform() !== "win64")
			return path.sep +
				(path.resolve(path.normalize(pathName)).replace(/^[\s\\\/]*|[\s\\\/]*$/g, ""))
				+ path.sep;
		else
			return path.resolve(path.normalize(pathName)) + path.sep;
	}

	/**
	 * Receives a path and call a callback for every folder until the root layer was reached
	 *
	 * @param {string} pathName
	 * @param callback
	 */
	static traversePathUpwards(pathName, callback) {
		pathName = PathFinder.unifyPath(pathName);
		const pathParts = pathName.split(path.sep);
		while (pathParts.length > 0) {
			let testDir = path.join(...pathParts);
			if (testDir === "." || !!testDir.match(/:\.$/g)) break;
			if(os.platform() !== "win32" && os.platform() !== "win64")
				testDir = path.sep + (testDir.replace(/^[\s\\\/]*|[\s\\\/]*$/g, "")) + path.sep;
			const callbackResult = callback(testDir);
			if (callbackResult === true) break;
			pathParts.pop();
		}
	}
};