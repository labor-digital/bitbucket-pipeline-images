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
 * Last modified: 2019.03.15 at 16:21
 */
const program = require("commander");
const ReleaseAction = require("./ReleaseAction");

program
	.option("--debug", "enables debug mode")
	.option("--dry-run", "only shows the changes without doing anything")
	.option("--skip-commit", "prevents standard version from creating a new git commit")
	.option("--skip-tag", "prevents standard version from creating a new git tag")
	.option("--git-push", "pushes the changes (back) into to the git repository")
	.option("--npm-publish", "publishes the package to the npm repository")
	.option("--composer-publish", "publishes the package to the satis repository")
	.option("--remove-release-tag", "removes the git tag called \"release\" from the git history. Useful if you want to use it to trigger yur pipelines with it")
	.option("--no-skip-ci", "do not add [SKIP CI] to the pushback commit message")
	.option("--release-as <type>", "can be used to manually bump the version to patch, minor or major", /major|minor|patch/)
	.option("--branch <branch>", "the branch where to commit the changes to. Default is \"master\"")
	.option("--ci-integration", "DEPRECATED: does nothing")
	.option("--src-dir <srcDir>", "The relative path of the folder where we can find a package.json or composer.json")
	.action(ReleaseAction.handle)
	.parse(process.argv);