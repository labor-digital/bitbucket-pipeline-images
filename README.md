# Some Docker images you can use in your Bitbucket pipelines #
This repo contains several docker images which you can use for different build steps in your Bitbucket pipelines yaml


## build-docker-and-push-ecr ##

This image could be used to build a docker image and push it to AWS ECR.
The following Env vars need to be set:

- BUILD_AND_PUSH_REGION (e.g. eu-central-1)
- BUILD_AND_PUSH_IMAGE (e.g. your-registry/your-image:your-tag)
- BUILD_AND_PUSH_DOCKER_FILE (default: "Dockerfile", e.g. "Dockerfile.dev")
- AWS_ACCESS_KEY_ID (in our environment this one is set account-wide, so you don´t need to set it)
- AWS_SECRET_ACCESS_KEY (in our environment this one is set account-wide, so you don´t need to set it)

#### Example ####

In this example the following Env vars are set:

- AWS_ECR_DEFAULT_REGION (in our environment this one is set account-wide)
- AWS_ECR_DEFAULT_URL (in our environment this one is set account-wide)
- AWS_ACCESS_KEY_ID (in our environment this one is set account-wide)
- AWS_SECRET_ACCESS_KEY (in our environment this one is set account-wide)
- PROJECT_NAME (this one is set in the project, e.g. adobe-adaa-showcase)

##### bitbucket-pipelines.yml #####

    pipelines:
      default:
        - step:
            image: labordigital/bitbucket-pipeline-images:build-docker-and-push-ecr
            name: Build and Push
            caches:
              - docker
            services:
              - docker
            script:
              - export BUILD_AND_PUSH_REGION=$AWS_ECR_DEFAULT_REGION
              - export BUILD_AND_PUSH_IMAGE=$AWS_ECR_DEFAULT_URL/$PROJECT_NAME:$BITBUCKET_COMMIT
              - cat /opt/build-docker-and-push-ecr.sh
              - source /opt/build-docker-and-push-ecr.sh



## deploy-docker-to-ecs ##

This image could be used to deploy a docker image on AWS ECS.
The following Env vars need to be set:

- DEPLOY_TO_ECS_ECR_REGION (the region of the ECR, where to docker image is, e.g. eu-central-1)
- DEPLOY_TO_ECS_ECR_URL (the url of the ECR, e.g. 848331400135.dkr.ecr.eu-central-1.amazonaws.com)
- DEPLOY_TO_ECS_ECR_IMAGE (the name of the docker image, e.g. adobe-adaa-showcase)
- DEPLOY_TO_ECS_ECR_TAG (the tag of the docker image)
- DEPLOY_TO_ECS_ECS_REGION (the region of the ECS, where the service runs, e.g. us-east-1)
- DEPLOY_TO_ECS_ECS_TASK (the ECS task name, e.g. service-ado-ada-adm-p-Task)
- DEPLOY_TO_ECS_ECS_CLUSTER (the ECS cluster to deploy to, e.g. labordec2-us-e2-cl-Ecscluster)
- DEPLOY_TO_ECS_ECS_SERVICE (the name of the ECS service, e.g. service-ado-ada-adm-p-Service)
- AWS_ACCESS_KEY_ID (in our environment this one is set account-wide, so you don´t need to set it)
- AWS_SECRET_ACCESS_KEY (in our environment this one is set account-wide, so you don´t need to set it)

#### Example ####

In this example the following Env vars are set:

- AWS_ECR_DEFAULT_REGION (in our environment this one is set account-wide)
- AWS_ECR_DEFAULT_URL (in our environment this one is set account-wide)
- AWS_ACCESS_KEY_ID (in our environment this one is set account-wide)
- AWS_SECRET_ACCESS_KEY (in our environment this one is set account-wide)
- PROJECT_NAME (this one is set in the project, e.g. adobe-adaa-showcase)
- AWS_ECS_CLUSTER (this one is set in the project, e.g. labordec2-us-e2-cl-Ecscluster)
- AWS_ECS_REGION (this one is set in the project, e.g. us-east-1)
- AWS_ECS_SERVICE (this one is set in the project, e.g. service-ado-ada-adm-p-Service)
- AWS_ECS_TASK (this one is set in the project, e.g. service-ado-ada-adm-p-Task)

##### bitbucket-pipelines.yml #####

    pipelines:
      default:
        - step:
            image: labordigital/bitbucket-pipeline-images:deploy-docker-to-ecs
            name: Deploy to production
            services:
              - docker
            trigger: manual
            deployment: production
            script:
              - export DEPLOY_TO_ECS_ECR_REGION=$AWS_ECR_DEFAULT_REGION
              - export DEPLOY_TO_ECS_ECR_URL=$AWS_ECR_DEFAULT_URL
              - export DEPLOY_TO_ECS_ECR_IMAGE=$PROJECT_NAME
              - export DEPLOY_TO_ECS_ECR_TAG=$BITBUCKET_COMMIT
              - export DEPLOY_TO_ECS_ECS_REGION=$AWS_ECS_REGION
              - export DEPLOY_TO_ECS_ECS_TASK=$AWS_ECS_TASK
              - export DEPLOY_TO_ECS_ECS_CLUSTER=$AWS_ECS_CLUSTER
              - export DEPLOY_TO_ECS_ECS_SERVICE=$AWS_ECS_SERVICE
              - source /opt/deploy-docker-to-ecs.sh



## composer-install ##

This image could be used to make a composer install.
The following Env vars need to/may be set:

#### IMPORTANT - Composer V2 ####
By default, we will use composer v1 to perform the installation. If you want to work with version 2 of composer,
replace the image tag to use: labor-prod-pipelines:composer-2-install instead.

**Required:**

- COMPOSER_INSTALL_SOURCE_DIR (This is the directory where the source code is at the beginning, so $COMPOSER_INSTALL_SOURCE_DIR/composer.json needs to be present)
- COMPOSER_INSTALL_WORKING_DIR (This is the directory, where the "composer install" will take place. The sources will be copied from $COMPOSER_INSTALL_SOURCE_DIR and then back to $COMPOSER_INSTALL_DESTINATION_DIR)

**Optional:**

- COMPOSER_INSTALL_SSH_KEY (_DEFAULT: "${BITBUCKET_DEFAULT_SSH_KEY}"_, which is set account-wide)
- COMPOSER_INSTALL_KNOWN_HOSTS (_DEFAULT: "${BITBUCKET_DEFAULT_KNOWN_HOSTS}"_, which is set account-wide)
- COMPOSER_INSTALL_DESTINATION_DIR (_DEFAULT: "${COMPOSER_INSTALL_SOURCE_DIR}"_, which is the directory where the code is copied with all composer-dependencies)

#### Example ####

In this example the following Env vars are set:

- BITBUCKET_DEFAULT_SSH_KEY (in our environment this one is set account-wide)
- BITBUCKET_DEFAULT_KNOWN_HOSTS (in our environment this one is set account-wide)
- BITBUCKET_CLONE_DIR (in our environment this one is set account-wide)
- AWS_ACCESS_KEY_ID (in our environment this one is set account-wide)
- AWS_SECRET_ACCESS_KEY (in our environment this one is set account-wide)

##### bitbucket-pipelines.yml #####

    pipelines:
      default:
        - step:
            image: labordigital/bitbucket-pipeline-images:composer-install
            name: Composer Install
            caches:
              - composer
          	script:
              - export COMPOSER_INSTALL_SSH_KEY=$BITBUCKET_DEFAULT_SSH_KEY
              - export COMPOSER_INSTALL_KNOWN_HOSTS=$BITBUCKET_DEFAULT_KNOWN_HOSTS
              - export COMPOSER_INSTALL_SOURCE_DIR=$BITBUCKET_CLONE_DIR/src
              - export COMPOSER_INSTALL_DESTINATION_DIR=$BITBUCKET_CLONE_DIR/src
              - export COMPOSER_INSTALL_WORKING_DIR=/var/www/html
              - source /opt/composer-install.sh
            artifacts:
              - src/vendor/**



## inject-aws-ecs-startup-script ##

This image is used to get the startup script which is needed for AWS ECS into the production image.
The following Env vars need to be set:

- INJECT_AWS_ECS_STARTUP_SCRIPT_SSH_KEY (e.g. $BITBUCKET_DEFAULT_SSH_KEY, which is set account-wide)
- INJECT_AWS_ECS_STARTUP_SCRIPT_KNOWN_HOSTS (e.g. $BITBUCKET_DEFAULT_KNOWN_HOSTS, which is set account-wide)
- INJECT_AWS_ECS_STARTUP_SCRIPT_GIT_INFRASTRUCTURE (e.g. adobe-aela-submissionsite.infrastructure, Git-Infrastructure-Repo where we want to fetch the startup-script)

#### Example ####

In this example the following Env vars are set:

- BITBUCKET_DEFAULT_SSH_KEY (in our environment this one is set account-wide)
- BITBUCKET_DEFAULT_KNOWN_HOSTS (in our environment this one is set account-wide)
- AWS_ACCESS_KEY_ID (in our environment this one is set account-wide)
- AWS_SECRET_ACCESS_KEY (in our environment this one is set account-wide)
- PROJECT_GIT_INFRASTRUCTURE (This one is set to adobe-aela-submissionsite.infrastructure in our example-project)

##### bitbucket-pipelines.yml #####

    pipelines:
      default:
        - step:
            image: labordigital/bitbucket-pipeline-images:inject-aws-ecs-startup-script
            name: Inject AWS ECS Startup Script
          	script:
              - export INJECT_AWS_ECS_STARTUP_SCRIPT_SSH_KEY=$BITBUCKET_DEFAULT_SSH_KEY
              - export INJECT_AWS_ECS_STARTUP_SCRIPT_KNOWN_HOSTS=$BITBUCKET_DEFAULT_KNOWN_HOSTS
              - export INJECT_AWS_ECS_STARTUP_SCRIPT_GIT_INFRASTRUCTURE=$PROJECT_GIT_INFRASTRUCTURE
              - source /opt/inject-aws-ecs-startup-script.sh
          	artifacts:
              - src/_git_infrastructure/aws_container_fetch_env.sh



## npm-run-build ##

This image could be used to build your assets with "npm run build".
The following Env vars need to/may be set:

**Required:**

- NPM_RUN_BUILD_WORKING_DIR (This is the directory, where the "npm run build" will take place.)

**Optional:**

- NPM_RUN_BUILD_REGISTRY_URL (_DEFAULT: "${NPM_DEFAULT_REGISTRY_URL}"_, which is set account-wide)
- NPM_RUN_BUILD_REGISTRY_EMAIL (_DEFAULT: "${NPM_DEFAULT_REGISTRY_EMAIL}"_, which is set account-wide)
- NPM_RUN_BUILD_REGISTRY_USER (_DEFAULT: "${NPM_DEFAULT_REGISTRY_USER}"_, which is set account-wide)
- NPM_RUN_BUILD_REGISTRY_PW (_DEFAULT: "${NPM_DEFAULT_REGISTRY_PW}", which is set account-wide)

#### Example ####

In this example the following Env vars are set:

- NPM_DEFAULT_REGISTRY_URL (in our environment this one is set account-wide)
- NPM_DEFAULT_REGISTRY_EMAIL (in our environment this one is set account-wide)
- NPM_DEFAULT_REGISTRY_USER (in our environment this one is set account-wide)
- NPM_DEFAULT_REGISTRY_PW (in our environment this one is set account-wide)
- BITBUCKET_CLONE_DIR (in our environment this one is set account-wide)
- AWS_ACCESS_KEY_ID (in our environment this one is set account-wide)
- AWS_SECRET_ACCESS_KEY (in our environment this one is set account-wide)

##### CAUTION: The bitbucket-pipelines cache "node" only works if your directly working in the project root. Otherwise you have to define your own cache. In our case here "node-custom" #####

##### bitbucket-pipelines.yml #####

	definitions:
	  caches:
	    node-custom: src/node_modules
	pipelines:
      default:
        - step:
            image: labordigital/bitbucket-pipeline-images:npm-run-build
            name: Build Assets
            caches:
              - node-custom
            script:
              - export NPM_RUN_BUILD_REGISTRY_URL=$NPM_DEFAULT_REGISTRY_URL
              - export NPM_RUN_BUILD_REGISTRY_EMAIL=$NPM_DEFAULT_REGISTRY_EMAIL
              - export NPM_RUN_BUILD_REGISTRY_USER=$NPM_DEFAULT_REGISTRY_USER
              - export NPM_RUN_BUILD_REGISTRY_PW=$NPM_DEFAULT_REGISTRY_PW
			  - export NPM_RUN_BUILD_WORKING_DIR=$BITBUCKET_CLONE_DIR/src
              - source /opt/npm-run-build.sh
            artifacts:
              - src/webroot/css/styles.css
              - src/webroot/js/root.js
              
              
## node-environment ##

This image provides you a basic node.js environment you can use to run your scripts in.
It is currently based on node 10 (2019-03-19 lts) and comes with two helper scripts preinstalled.
The following Env vars need to/may be set:

**Optional: /opt/npm-login.sh**

- NPM_REGISTRY_URL (_DEFAULT: "${NPM_DEFAULT_REGISTRY_URL}"_, which is set account-wide)
- NPM_REGISTRY_EMAIL (_DEFAULT: "${NPM_DEFAULT_REGISTRY_EMAIL}"_, which is set account-wide)
- NPM_REGISTRY_USER (_DEFAULT: "${NPM_DEFAULT_REGISTRY_USER}"_, which is set account-wide)
- NPM_REGISTRY_PW (_DEFAULT: "${NPM_DEFAULT_REGISTRY_PW}", which is set account-wide)

**Optional: /opt/npm-run-script.sh**

- NODE_WORKING_DIR (_DEFAULT: "${BITBUCKET_CLONE_DIR}"_, which is set in all pipelines)

#### Scripts ####
**/opt/npm-login.sh**
Performs the login to our verdaccio npm repository.

**/opt/npm-run-script.sh <script-name-and-options>**
Performs the login to our verdaccio npm repository, switches the working directory, installs the npm dependencies and runs a given script with "npm run..."

**/opt/npm-run-script-without-login.sh <script-name-and-options>**
The same as /opt/npm-run-script.sh but without the automatic login

#### Example ####

##### CAUTION: The bitbucket-pipelines cache "node" only works if your directly working in the project root. Otherwise you have to define your own cache. #####

##### bitbucket-pipelines.yml #####

	pipelines:
      default:
        - step:
            image: labordigital/bitbucket-pipeline-images:node-environment
            name: Build Assets
            caches:
              - node
            script:
              - source /opt/npm-login.sh
              - source /opt/npm-run-script.sh test

              
## deployment-tools ##
Small debian image which contains curl, zip and and open-ssh client

##### bitbucket-pipelines.yml - SSH #####
```
      deploy:
        -
          step: &deploy
            image: labordigital/bitbucket-pipeline-images:deployment-tools
            name: Deploy
            deployment: production
          script:
            - >
              ssh $SSH_USER@$SSH_SERVER "
              YOUR && 
              commands && 
              to && 
              execute"
```

##### bitbucket-pipelines.yml - CURL #####
```
    ghostInspector:
      -
        step: &ghostInspectorTest
          image: labordigital/bitbucket-pipeline-images:deployment-tools
          name: Ghost Inspector Test
          script:
            - curl "https://api.ghostinspector.com/v1/suites/$GI_SUITE/execute/?apiKey=$GI_API_KEY&immediate=1&region=eu-central-1"

```

## conventional-release ##
Contains the infrastructure to an automatic release cycle based on [Conventional Changelog](https://github.com/conventional-changelog/conventional-changelog) and [angular's commit guidelines](https://github.com/angular/angular.js/blob/master/DEVELOPERS.md#-git-commit-guidelines). Both provide tools to keep the git history readable, generate version numbers and changelogs automatically. 
It expects your package.json / composer.json and CHANGELOG.md to reside in the repository's root directory.

##### Config variables #####
By default the image will take our account environment variables,
but you may override them with the following OPTIONAL environment vars.

**Optional:**

- RELEASE_DIR (_DEFAULT: "${BITBUCKET_CLONE_DIR}"_, which is the directory, where the "release" will take place.)
- GIT_PUSH_BACK_OAUTH_ID (_DEFAULT: "${GIT_OAUTH_ID}"_, which is set account-wide)
- GIT_PUSH_BACK_OAUTH_SECRET (_DEFAULT: "${GIT_OAUTH_SECRET}"_, which is set account-wide)
- GIT_PUSH_BACK_REPO_OWNER (_DEFAULT: "${BITBUCKET_REPO_OWNER}"_, which is set in all pipelines)
- GIT_PUSH_BACK_REPO_SLUG (_DEFAULT: "${BITBUCKET_REPO_SLUG}"_, which is set in all pipelines)
- NPM_REGISTRY_URL (_DEFAULT: "${NPM_DEFAULT_REGISTRY_URL}"_, which is set account-wide)
- NPM_REGISTRY_USER (_DEFAULT: "${NPM_DEFAULT_REGISTRY_USER}"_, which is set account-wide)
- NPM_REGISTRY_PW (_DEFAULT: "${NPM_DEFAULT_REGISTRY_PW}}"_, which is set account-wide)
- NPM_REGISTRY_EMAIL (_DEFAULT: "${NPM_DEFAULT_REGISTRY_EMAIL}"_, which is set account-wide)

##### /opt/release.sh - Arguments #####
Flags can be used to preconfigure the release step. In general, they are meant to configure the release without any means of interaction, but work in a local installation as well (If a flag is set the representing wizard input will be skipped.).
The following flags are available: 
```
  --skip-commit         prevents standard version from creating a new git commit
  --skip-tag            prevents standard version from creating a new git tag
  --git-push            pushes the changes (back) into to the git repository
  --npm-publish         publishes the package to the npm repository
  --composer-publish    publishes the package to the satis repository
  --remove-release-tag  removes the git tag called "release" from the git history. Useful if you want to use it to trigger yur pipelines with it
  --release-as <type>   can be used to manually bump the version to patch, minor or major
  --branch <branch>     the branch where to commit the changes to. Default is \"master\"

  --ci-integration      DEPRECATED - no longer does anything
```

##### bitbucket-pipelines.yml #####
```
      release:
        -
          step: &release
            image: labordigital/bitbucket-pipeline-images:conventional-release 
            name: Release
          script:
            - source /opt/release.sh --git-push --composer-publish --npm-publish
          artifacts:
            - src/CHANGELOG.md
```

## sentry-release ##
Contains the required scripts to prepare a new release for [sentry.io](https://sentry.io/). Sentry is an error/log aggregator that
can be implemented either in the backend, frontend or both environments. There are two ways to use sentry.
First the simple way where you just create a sentry project and start logging errors with their sdk.
However, there is a second more advanced way that uses releases.

This pipeline script helps you to perform the second way. It will create a new [release](https://docs.sentry.io/workflow/releases/?_ga=2.43897381.1016733809.1573752645-1737300819.1573752645&platform=php#setting-up-releases) 
and supply the generated configuration to the subsequent build steps. 

The first step is to create a new sentry project, than use the bitbucket integration to
read your commit data. After that you can use this package. Please note, that you have to add **two Build steps** to 
your pipeline script! One at the top and one at the bottom.

To make sure the sync between sentry and your project works without issues make sure your sentry.io project matches
the value of bitbucket's $BITBUCKET_REPO_SLUG environment variable (which is also a part of the bitbucket repository url). Alternatively you have to set SENTRY_PROJECT manually to match sentry's name.

The first script will provide the ${BITBUCKET_CLONE_DIR}/sentry-configuration-file.json for other steps.
So make sure you run this step before your other pipeline steps that might depend on it.

##### Config variables #####
Most of the configuration is done using our repository variables,
but there are still some required environment variables you have to set.

**Required: /opt/sentry-prepare-release.sh**

- SENTRY_DSN (You can find this in your sentry project's settings under "Client Keys")

**Optional: /opt/sentry-prepare-release.sh**

- SENTRY_RELEASE_TOKEN (_DEFAULT: "${SENTRY_RELEASE_TOKEN}"_, the sentry.io api token that is used to publish the release to sentry)
- SENTRY_ORGANIZATION (_DEFAULT: "${SENTRY_ORGANIZATION}"_, the organization/account name you want to create the release with)
- SENTRY_RELEASE (_DEFAULT: "${BITBUCKET_COMMIT}"_, the name of the version/release to create. This will be your commit sha by default)
- SENTRY_PROJECT (_DEFAULT: "${BITBUCKET_REPO_SLUG}"_, the name of the project to create the release on. Matches the repository name by default)
- SENTRY_CONFIG_FILE_LOCATION (_DEFAULT: "${BITBUCKET_CLONE_DIR}/sentry-configuration-file.json"_, holds the compiled information for other build steps to use)

#### Scripts ####
**/opt/sentry-prepare-release.sh**
Should be called as first pipeline script. It will register a new sentry release and connect the git commits with it.
It will also provide a global configuration file as artifact for other build steps.

**/opt/sentry-release.js**
Should be called as the last possible script, after you deployed your script to production.

##### bitbucket-pipelines.yml #####
```
      sentryPrepareRelease:
        -
          step: &sentryPrepareRelease
            image: labordigital/bitbucket-pipeline-images:sentry-release 
            name: "Sentry.io: Prepare Release"
          script:
            - source /opt/sentry-prepare-release.sh
          artifacts:
            - sentry-configuration-file.json

      [... YOUR OTHER PIPELINE STEPS ...]

      sentryDeployRelease:
        -
          step: &sentryDeployRelease
            image: labordigital/bitbucket-pipeline-images:sentry-release 
            name: "Sentry.io: Deploy Release"
          script:
            - source /opt/sentry-release.sh
```
