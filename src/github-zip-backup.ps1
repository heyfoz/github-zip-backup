#!/usr/bin/env pwsh
# File header specifies pwsh interpreter location for Linux and MacOS

# GitHub API Documentation: 
# https://docs.github.com/en/rest/repos/contents?apiVersion=2022-11-28#download-a-repository-archive-zip

$username = "insertGitHubUsername"

# Get the user's repositories via github api rest method
$uri = "https://api.github.com/users/$username/repos?per_page=1000"
$repositories = Invoke-RestMethod -Uri $uri

# Download zip files for each repository
foreach ($repo in $repositories) {
    $name = $repo.name
    $zipUri = $repo.archive_url -replace '{archive_format}{/ref}', 'zipball/master'
    $zipFile = "$name.zip"
    Write-Host "Downloading $name..."
    Invoke-WebRequest -Uri $zipUri -OutFile $zipFile
    # Try to check for/download master branch. If not found, check for/download main branch
    try {
        Invoke-WebRequest -Uri $zipUri -OutFile $zipFile -ErrorAction Stop
    } catch {
        # Invoke-WebRequest returns 404 error in $_.Exception.Message if branch not found
        if ($_.Exception.Message -match '404') {
            $zipUri = $repo.archive_url -replace '{archive_format}{/ref}', 'zipball/main'
            Invoke-WebRequest -Uri $zipUri -OutFile $zipFile -ErrorAction Stop
        } 
        # Specify repo name in warning
        else { 
            Write-Warning "Error downloading $name: $($_.Exception.Message)"
        }
    }
}
