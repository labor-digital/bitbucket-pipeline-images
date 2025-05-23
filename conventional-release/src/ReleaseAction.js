/*
 * Copyright 2021 LABOR.digital
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
 * Last modified: 2020.03.23 at 12:13
 */

let newVersion = null;
const PathFinder = require("./PathFinder");
const fs = require("fs");
const cp = require("child_process");
const path = require("path")
const got = require("got");
const standardVersion = require("standard-version");

module.exports = class ReleaseAction {

	static handle(cmd) {
		const config = {
			satisRequestTimeout: 60 * 10 * 1000,
			debug: cmd.debug === true,
			dryRun: cmd.dryRun === true,
			branch: (typeof cmd.branch === "undefined" ? "master" : cmd.branch)
		};
		const releaseElements = PathFinder.findReleaseElements(true, (typeof cmd.srcDir === "undefined" ? null : cmd.srcDir));

		// Make changelog path relative
		const rootDirectory = releaseElements.git === null ? releaseElements.config : releaseElements.git;
		const infile = releaseElements.changelogMd;
		const infileRelative = path.relative(releaseElements.config, infile);

		// Try to read tags on current commit, if skipOnTag option is set
		if (cmd.skipOnTag === true && releaseElements.git !== null) {
			console.log("Try to read tags on current commit...");
			const command = "cd \"" + releaseElements.git + "\" && git describe --exact-match --tags";
			let tagAvailable = false;
			try {
				cp.execSync(command, {"stdio": "ignore"});
				// If the command has failed we don't have a tag on the current commit,
				// so we only set this here to true as we now know, that we have one,
				// as we're still in the try block
				tagAvailable = true;
			} catch (e) {
				// For completeness and readability
				tagAvailable = false;
			}

			if (tagAvailable) {
				console.log("Skip the whole process without error, as we have a tag present on this commit and --skip-on-tag option is set.");
				process.exit(0);
			} else {
				console.log("No tags found on this commit... Proceed.");
			}
		}

		// Apply some fixes and load standard-version
		ReleaseAction._applyAdjustmentsToStandardVersionBump();
		ReleaseAction._applyRewriteOfChangelogTemplatesForBitbucket();
		ReleaseAction._applyBugFixForConventionalChangelogNotGettingAVersionWhenNoPackageJson(releaseElements);

		// Prepare standard version environment
		const environment = {
			path: rootDirectory,
			infile: infileRelative,
			releaseAs: cmd.releaseAs,
			gitTagFallback: true,
			dryRun: config.dryRun,
			message: "chore(release): %s" + (cmd.skipCi === true ? " [SKIP CI]" : ""),
			skip: {}
		};
		if (config.debug === true) environment.verbose = true;
		if (cmd.skipCommit === true || releaseElements.git === null) environment.skip.commit = true;
		if (cmd.skipTag === true || releaseElements.git === null) environment.skip.tag = true;

		// Run standard version
		process.chdir(releaseElements.config);
		standardVersion(environment)
			.then(() => {
				// VERSION FILE
				// Dump a version file to pass the new version along to other build steps
				const versionFile = path.join(rootDirectory, "VERSION");
				console.log("Dumping a new version file at :\"" + versionFile + "\" containing: " + newVersion);
				fs.writeFileSync(versionFile, newVersion);
			})
			.then(() => {
				if (releaseElements.packageJson === null) {
					if (cmd.npmPublish === true)
						console.log("No package.json found... Skipping npm publish");
					return Promise.resolve();
				}
				// NPM PUBLISH
				const pjson = require(releaseElements.packageJson);
				const packageName = typeof pjson.name === "string" ? pjson.name : releaseElements.config;
				return new Promise((resolve, reject) => {
					(new Promise((resolve1, reject1) => {
						if (cmd.npmPublish === true) return resolve1();
						return reject1();
					})).then(() => {
						// Execute npm publish
						console.log("Publishing your package \"" + packageName + "\" to the npm repository...");
						const command = "cd \"" + path.dirname(releaseElements.packageJson) + "\" && npm publish";
						if (config.debug) console.log("Execute command: " + command);
						if (config.dryRun) return resolve();
						try {
							cp.execSync(command, {"stdio": "inherit"});
						} catch (e) {
							reject(e);
						}
						resolve();
					}).catch(() => {
						// Skip
						resolve();
					});
				});
			})
			.then(() => {
				// Remove Release tag
				return new Promise(resolve => {
					if (cmd.removeReleaseTag !== true) return resolve();
					console.log("Trying to remove \"release\" tag...");
					const command = "cd \"" + releaseElements.git + "\" && git push --delete origin release && git tag -d release";
					if (config.debug) console.log("Execute command: " + command);
					if (config.dryRun) return resolve();
					try {
						cp.execSync(command, {"stdio": "inherit"});
					} catch (e) {
					}
					resolve();
				});
			})
			.then(() => {
				// GIT PUSH
				return new Promise((resolve, reject) => {
					(new Promise((resolve1, reject1) => {
						if (releaseElements.git === null) {
							console.log("No git repository found... Skipping push");
							return reject1();
						}
						if (cmd.gitPush === true) return resolve1();
						if (cmd.skipCommit === true && cmd.skipTag === true) return reject1();
						return reject1();
					})).then(() => {
						// Execute npm publish
						console.log("Pushing changes and tags to the \"" + config.branch + "\" branch...");
						const command = "cd \"" + releaseElements.git + "\" && git push --follow-tags origin " + config.branch;
						if (config.debug) console.log("Execute command: " + command);
						if (config.dryRun) return resolve();
						try {
							cp.execSync(command, {"stdio": "inherit"});
						} catch (e) {
							reject(e);
						}
						resolve();
					}).catch(() => {
						// Skip
						resolve();
					});
				});
			})
			.then(() => {
				// Composer publish
				return new Promise((resolve, reject) => {
					(new Promise((resolve1, reject1) => {
						if (releaseElements.git === null) {
							console.log("No git repository found... Skipping composer publishing");
							return reject1();
						}
						if (releaseElements.composerJson === null) {
							console.log("No composer.json found... Skipping composer publishing");
							return reject1();
						}
						if (path.dirname(releaseElements.composerJson) !== path.resolve(releaseElements.git)) {
							console.log("The composer.json does not reside in the git root directory at: \"" + releaseElements.git + "\"! Skipping composer publishing");
							return reject1();
						}
						if (cmd.composerPublish === true) return resolve1();
						return reject1();
					})).then(() => {
						console.log("Publishing composer repository to satis...");

						const buildUrl = process.env.CONV_RELEASE_SATIS_BUILD_URL;
						if((buildUrl + '').trim() === '')
							return reject('Failed! Missing environment variable CONV_RELEASE_SATIS_BUILD_URL in your environment!');

						let originUrl = cp.execSync("cd \"" + releaseElements.git +
							"\" && git config --get remote.origin.url").toString("utf-8").replace(/[\r\n]+(.*)$/gm, "");
						if((originUrl + '').trim() === '')
							originUrl = process.env.BITBUCKET_GIT_SSH_ORIGIN;
						if((originUrl + '').trim() === '')
							return reject('Failed! Did not find a valid git remote to use as repository!');

						const requestUrl = buildUrl + encodeURIComponent(originUrl);
						if (config.debug === true) console.log("Triggering web API at: " + requestUrl);
						if (config.dryRun === true) return Promise.resolve();
						return got(requestUrl, {
							timeout: config.satisRequestTimeout
						}).then(response => {
							console.log(response.body);
							return Promise.resolve();
						}).catch(reject);
					}).catch(() => {
						// Skip
						resolve();
					});

				});
			})
			.catch(err => {
				console.error(err);
				process.exit(1);
			});
	}

	/**
	 * Wraps the "Bump" class of standard-version to make sure we determine a reliable version,
	 * even if all other methods of version guessing failed
	 * @internal
	 */
	static _applyAdjustmentsToStandardVersionBump() {
		const Bump = require("standard-version/lib/lifecycles/bump");
		const bumpPath = require.resolve("standard-version/lib/lifecycles/bump");
		const gitSemverTags = require("git-semver-tags");
		const semver = require("semver");

		// Create bump wrapper that provides a fallback version number
		const BumpWrapper = function (args, version) {

			// Make sure we always have a valid version number
			return (new Promise((resolve, reject) => {
				gitSemverTags(function (err, tags) {
					if (err !== null) return reject(err);
					let gitVersion = "v0.0.0";
					if (tags.length > 0) gitVersion = tags.shift();
					gitVersion = semver.clean(gitVersion);
					resolve(gitVersion);
				}, {tagPrefix: args.tagPrefix});
			})).then(gitVersion => {
				if (version === null || typeof version === "undefined" || semver.gt(gitVersion, version))
					version = gitVersion;

				// Call the real bump method
				return Bump(args, version).then(version => {
					newVersion = version;
					return Promise.resolve(version);
				});
			});
		};
		BumpWrapper.getUpdatedConfigs = Bump.getUpdatedConfigs;
		BumpWrapper.pkgFiles = Bump.pkgFiles;
		BumpWrapper.lockFiles = Bump.lockFiles;

		// Inject wrapper
		require.cache[bumpPath].exports = BumpWrapper;
	}

	/**
	 * Somehow there is a strange bug in conventional-changelog (used internally by standardVersion to generate the changelog)
	 * that causes the changelog generation to break because when there is no package.json file present.
	 * To circumvent that we will supply it with the version number we extracted from the bump script.
	 * @private
	 */
	static _applyBugFixForConventionalChangelogNotGettingAVersionWhenNoPackageJson(releaseElements) {
		if (releaseElements.packageJson !== null) return;
		const cc = require("conventional-changelog");
		const ccPath = require.resolve("conventional-changelog");

		// Inject wrapper
		require.cache[ccPath].exports = function (options, context, gitRawCommitsOpts, parserOpts, writerOpts) {
			if (typeof context === "object" && typeof context !== "undefined") context.version = newVersion;
			else context = {version: newVersion};
			return cc(options, context, gitRawCommitsOpts, parserOpts, writerOpts);
		};
	}

	/**
	 * By default the "conventional-changelog-angular" preset we use by default assumes that
	 * our path's have to work with github, but we work with bitbucket, so we have to adjust some
	 * path templates to work as expected
	 * @private
	 */
	static _applyRewriteOfChangelogTemplatesForBitbucket() {
		const cc = require("conventional-changelog-core");
		const ccPath = require.resolve("conventional-changelog-core");

		// Inject wrapper
		require.cache[ccPath].exports = function (options, context, gitRawCommitsOpts, parserOpts, writerOpts) {
			options.config = options.config.then(function (args) {
				// Adjust compare path
				args.writerOpts.headerPartial =
					args.writerOpts.headerPartial.replace(
						/\/compare\/{{previousTag}}\.\.\.{{currentTag}}/gm,
						"/branches/compare/{{currentTag}}%0D{{previousTag}}#diff");
				return Promise.resolve(args);
			});
			return cc(options, context, gitRawCommitsOpts, parserOpts, writerOpts);
		};
	}
};