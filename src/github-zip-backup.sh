#!/bin/bash
# File header specifies location of bash shell interpreter

# This shell script (bash) saves zip file copies of private and public GitHub repos based on username, personal access token parameters

# GitHub API Documentation: 
# https://docs.github.com/en/rest/repos/contents?apiVersion=2022-11-28#download-a-repository-archive-zip

# Set the username, authorization token, and destination directory
USERNAME="insertGitHubUsername"
TOKEN="insertGitHubAccessToken"
DIRECTORY="C:\path\to\directory"

# Get list of repository names (explained at bottom of file)
repos=$(curl -s -H "Authorization: token $TOKEN" "https://api.github.com/users/$USERNAME/repos?type=all&per_page=1000" | grep -Eo '"full_name": "[^"]+"' | awk '{print $2}' | tr -d \")

# Loop through repositories
for repo in $repos
# Check for main | master default branches
do
  BRANCH=$(curl -s -H "Authorization: token $TOKEN" "https://api.github.com/repos/$repo/branches" | grep -E 'name.*(main|master)' | cut -d'"' -f4)
  # If the repository has a master or main default branch, download it as a zip archive.
  if [[ ! -z "$BRANCH" ]]; then
    echo "Downloading $repo as zip archive..."
    curl -sL -H "Authorization: token $TOKEN" "https://api.github.com/repos/$repo/zipball/$BRANCH" -o "$DIRECTORY/${repo##*/}.zip"
  fi
done

# Part 1: curl_command="curl -s -H \"Authorization: token $TOKEN\" https://api.github.com/users/$USERNAME/repos?type=all&per_page=1000"
# Use curl to send a GET request to the GitHub API.
# The "-s" option silences curl's progress output.
# The "-H" option specifies a request header, the Authorization header with your GitHub Personal Access Token ($TOKEN)
# The URL retrieves all repositories ("repos") for a given user ($USERNAME), up to a maximum of 1000 repositories per page.
# The output of this command will be a JSON response containing details about each repository.

# Part 2: grep_command="grep -Eo '\"full_name\": \"[^\"]+\"'"
# Pipe (|) sends the output of the previous command to grep.
# grep filters the output.
# The "-Eo" option tells grep to only show the part of a line matching the pattern and to interpret the pattern as an extended regular expression.
# The pattern '"full_name": "[^"]+"' matches the full name of each repository, including the username and repo name.

# Part 3: awk_command="awk '{print $2}'"
# The output of grep is sent to awk.
# awk manipulates structured data.
# The '{print $2}' script tells awk to print the second field of each line, which is the full name of the repository in this case.

# Part 4: tr_command="tr -d '\"'"
# The output of awk is sent to tr.
# tr translates or deletes characters.
# The '-d' option tells tr to delete each input character in its argument (in this case, the quotation mark character), removing quotes from the repo names.

# Combine all the commands/parts to get the list of repository names.
# repos=$($curl_command | $grep_command | $awk_command | $tr_command)
