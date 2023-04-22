#!/bin/bash

# GitHub API Documentation: 
# https://docs.github.com/en/rest/repos/contents?apiVersion=2022-11-28#download-a-repository-archive-zip

# Set the username, authorization token, and destination directory
USERNAME="insertGitHubUsername"
TOKEN="insertGitHubAccessToken"
DIRECTORY="C:\path\to\directory"

# Get list of repository names
repos=$(curl -s -H "Authorization: token $TOKEN" "https://api.github.com/users/$USERNAME/repos?type=all&per_page=1000" | grep -Eo '"full_name": "[^"]+"' | awk '{print $2}' | tr -d \")

# Loop through repositories
for repo in $repos
# Check for main | master default branches
do
  BRANCH=$(curl -s -H "Authorization: token $TOKEN" "https://api.github.com/repos/$repo/branches" | grep -E 'name.*(main|master)' | cut -d'"' -f4)
  # If the repository has a master or main default branch, download it as a zip archive
  if [[ ! -z "$BRANCH" ]]; then
    echo "Downloading $repo as zip archive..."
    curl -sL -H "Authorization: token $TOKEN" "https://api.github.com/repos/$repo/zipball/$BRANCH" -o "$DIRECTORY/${repo##*/}.zip"
  fi
done
