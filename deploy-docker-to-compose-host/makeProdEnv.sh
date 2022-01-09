#!/bin/bash

if [ -z "$1" ];  then
        echo "  [!] No argument supplied, this script expects the project-env to run."
        exit 1
fi

projectEnv = $1

# Remove current env file
rm -f .env

emptyLineReg="^\s+$"
emptyValueReg=".*?=($|\s*$)"

# Read the .env.template file
out=""
if [ -e .env.template ]; then
  for LINE in `cat .env.template`; do
    if [[ $LINE =~ $emptyLineReg ]]; then continue; fi
    if [[ $LINE =~ $emptyValueReg ]]; then continue; fi

    out+="$LINE
"
  done
  echo "  [+] .env.template contents added"
else
  echo "  [?] No .env.template found, skip..."
fi

# Read the .env.app.template file
if [ -e .env.app.template ]; then
  for LINE in `cat .env.app.template`; do
    if [[ $LINE =~ $emptyLineReg ]]; then continue; fi
    if [[ $LINE =~ $emptyValueReg ]]; then continue; fi

    out+="$LINE
"
  done
  echo "  [+] .env.app.template contents added"
else
  echo "  [?] No .env.app.template found, skip..."
fi

# Read .env.prod file
if [ -e ".env.$projectEnv" ]; then
	for LINE in `cat .env.$projectEnv`; do
    if [[ $LINE =~ $emptyLineReg ]]; then continue; fi
    if [[ $LINE =~ $emptyValueReg ]]; then continue; fi

    out+="$LINE
"
	done
  echo "  [+] .env.$projectEnv contents added"
else
  echo "  [?] No .env.$projectEnv found, skip..."
fi

# Add additional env vars that start with ADD_PROD_ENV_*
unset IFS
for var in $(compgen -e); do
  if [[ $var == ADD_PROD_ENV_* ]]; then
    out+="${var:13}=${!var}
"
  fi
done

# Write the .env file
echo "$out" > .env