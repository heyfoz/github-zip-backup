#!/bin/bash

# Replace the username with your GitHub username
username="insertGitHubUsernameHere"

# Get a list of all repositories for the user
repositories=$(curl -s httpsapi.github.comusers$usernamereposper_page=1000  grep -o 'git@[^]')

# Download zip files for each repository
for repo in $repositories; do
    name=$(echo $repo  cut -d'' -f2  cut -d'.' -f1)
    echo Downloading $name
    curl -L -o $name.zip $repoarchivemaster.zip
done
