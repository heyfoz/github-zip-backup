#!/usr/bin/env pwsh
# File header specifies pwsh interpreter location for Linux and MacOS

# This script saves zip file copies of public GitHub repos based on username parameters
# GitHub API Documentation: 
# https://docs.github.com/en/rest/repos/contents?apiVersion=2022-11-28#download-a-repository-archive-zip

# GitHub username used to retrieve public repos (access token required for private repos)
$username = "insertGitHubUsername"

# Get the repositories for the user
$uri = "https://api.github.com/users/$username/repos?per_page=1000"
$repositories = Invoke-RestMethod -Uri $uri

# Initialize int variables to keep track of the number of repositories downloaded
$totalRepos = $repositories.Count
$downloadedRepos = 0

# Download zip files for each repository
foreach ($repo in $repositories) {
    $name = $repo.name
    $zipUri = $repo.archive_url -replace '{archive_format}{/ref}', 'zipball/master'
    $zipFilePath = "C:\Users\forre\OneDrive\Dev\$($name).zip"
    Write-Host "Downloading $name"

    # Check for/download master branch, if not found, do same for main branch
    try {
        Invoke-WebRequest -Uri $zipUri -OutFile $zipFilePath -ErrorAction Stop
	  # Track number of downloaded repos
	  $downloadedRepos++
    } catch {
        if ($_.Exception.Message -match '404') {
            $zipUri = $repo.archive_url -replace '{archive_format}{/ref}', 'zipball/main'
            Invoke-WebRequest -Uri $zipUri -OutFile $zipFilePath -ErrorAction Stop
		$downloadedRepos++
        } 
	# Otherwise, display download error message
	else {
            Write-Warning "Error downloading $($name): $($_.Exception.Message)"
        }
    }
}
# Display the number of downloaded repos
Write-Host "$downloadRepos / $totalRepos repositories downloaded."
