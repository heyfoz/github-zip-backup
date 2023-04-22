#!/usr/bin/env pwsh
# File header specifies pwsh interpreter location for Linux and MacOS

# GitHub API Documentation: 
# https://docs.github.com/en/rest/repos/contents?apiVersion=2022-11-28#download-a-repository-archive-zip

$username = "ffm5113"

# Get the repositories for the user
$uri = "https://api.github.com/users/$username/repos?per_page=1000"
$repositories = Invoke-RestMethod -Uri $uri

# Download zip files for each repository
foreach ($repo in $repositories) {
    $name = $repo.name
    $zipUri = $repo.archive_url -replace '{archive_format}{/ref}', 'zipball/master'
    $zipFile = "$name.zip"
    Write-Host "Downloading $name"

    # check for master branch, if not found, check for main branch
    try {
        Invoke-WebRequest -Uri $zipUri -OutFile $zipFile -ErrorAction Stop
    } catch {
        if ($_.Exception.Message -match '404') {
            $zipUri = $repo.archive_url -replace '{archive_format}{/ref}', 'zipball/main'
            Invoke-WebRequest -Uri $zipUri -OutFile $zipFile -ErrorAction Stop
        } else {
            Write-Warning "Error downloading $($name): $($_.Exception.Message)"
        }
    }
}