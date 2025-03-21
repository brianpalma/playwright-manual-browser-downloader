<#
.SYNOPSIS
    Script to install Playwright browsers manually.

.DESCRIPTION
    This script uses the Playwright CLI to install the required browsers for Playwright testing.

.NOTES
    File Name  : installbrowsers.ps1
    Author     : Brian Palma
    Created On : 2025-03-21
    Version    : 1.0
#>

# Ensure the script stops on errors
Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"
$logFile = "installbrowsers.log"


# Check if the "--all" argument was passed to the script
if ($args.Count -gt 0 -and $args[0] -eq "--all") {
    $installAll = $true
    Write-Host "Option '--all' detected. All browsers will be installed without confirmation." -ForegroundColor Green
}else {
    $installAll = $false
}   

Write-Host "Starting Playwright browser installation..." -ForegroundColor Cyan

# Execute the Playwright install command
try {
    Write-Host "Perform a dry run of the Playwright browser installation to get the Browser's info." -ForegroundColor Magenta
    Write-Host ""
    # Run the Playwright install command with a dry run to get browser details
    $output = npx playwright install --dry-run 2>&1
    # Filter out all lines containing "Install location:"
    $installLocations = $output | Select-String -Pattern "Install location:"
    # Filter out all lines containing "browser:"
    $browserLines = $output | Select-String -Pattern "browser:"
    # Filter out all lines containing "Download url:"
    $browserUrls = $output | Select-String -Pattern "Download url:"

    if ($installLocations -and $browserLines -and $browserUrls) {
        
        for ($i = 0; $i -lt $browserLines.Count; $i++) {
            # Extract the browser name after "browser:"
            $browserName = ($browserLines[$i] -replace ".*browser:\s*([^\s]+).*", '$1')
            # Extract the browser download URL
            $browserUrl = ($browserUrls[$i] -replace ".*url:\s*([^\s]+).*", '$1')
            
            if (-not $installAll) {
                # Ask the user if they want to install the current browser
                $userResponse = Read-Host "Do you want to install $browserName ? (Press Enter for yes, or type no)"
                if ($userResponse -ne "" -and $userResponse -notmatch "^(yes|y)$") {
                    Write-Host "Skipping installation for $browserName." -ForegroundColor Yellow
                    continue
                }
            }
            Write-Host "Browser information and install locations for $browserName found:" -ForegroundColor Yellow
            
            # Create a variable with the browser name (first letter capitalized)
            $variableName = $browserName.Substring(0, 1).ToUpper() + $browserName.Substring(1)
            
            # Assign the browser name to the variable
            Set-Variable -Name $variableName -Value $browserName

            # Create a variable for the browser URL
            $variableUrl = $browserName.Substring(0, 1).ToUpper() + $browserName.Substring(1) + "Url"
            Set-Variable -Name $variableUrl -Value $browserUrl
            
            # Extract the corresponding path for the browser
            $path = $installLocations[$i] -replace ".*Install location:\s*", ""
            Write-Host "Install Path: $path" -ForegroundColor Cyan

            # Print the variable name and its content
            Write-Host "$variableUrl = $browserUrl" -ForegroundColor Cyan

            # Create the directory if it does not exist
            if (-not (Test-Path -Path $path)) {
                New-Item -ItemType Directory -Path $path -Force | Out-Null
            }

            # Build the full file path
            $fileName = [System.IO.Path]::GetFileName($browserUrl)
            $filePath = Join-Path -Path $path -ChildPath $fileName

            # Check if the path exists and is a directory
            if (Test-Path -Path $path -PathType Container) {
                # Delete the existing folder
                Write-Host "Folder already exists: $path. Deleting it..." -ForegroundColor Yellow
                Remove-Item -Path $path -Recurse -Force
                Write-Host "Folder deleted: $path" -ForegroundColor Cyan
            }

            # Recreate the folder after deletion
            Write-Host "Creating folder: $path..." -ForegroundColor Green
            New-Item -ItemType Directory -Path $path -Force | Out-Null
            Write-Host "Folder created: $path" -ForegroundColor Cyan

            # Download the file
            Write-Host "Downloading $variableUrl to $filePath..." -ForegroundColor Green
            Invoke-WebRequest -Uri $browserUrl -OutFile $filePath
            Write-Host "Download completed: $filePath" -ForegroundColor Cyan
            try {
                if (Test-Path -Path $filePath) {
                    # Get the directory where the ZIP file is located
                    $extractPath = Split-Path -Path $filePath
            
                    Write-Host "Extracting $filePath to $extractPath..." -ForegroundColor Green
                    Expand-Archive -Path $filePath -DestinationPath $extractPath -Force
                    Write-Host "Extraction completed: $extractPath" -ForegroundColor Cyan
            
                    # Delete the ZIP file after extraction
                    Write-Host "Deleting ZIP file: $filePath..." -ForegroundColor Green
                    Remove-Item -Path $filePath -Force
                    Write-Host "ZIP file deleted: $filePath" -ForegroundColor Cyan
                } else {
                    Write-Host "File not found: $filePath" -ForegroundColor Red
                }
            } catch {
                # Handle errors during extraction or deletion
                Write-Host "An error occurred while extracting or deleting the ZIP file." -ForegroundColor Red
                Write-Error $_
            }
            Write-Host ""
        }
    } else {
        # Handle case where no browser information or install locations are found
        Write-Host "No browser information or install locations found in the output." -ForegroundColor Red
    }

} catch {
    # Handle errors during the Playwright browser installation process
    $errorMessage = $_.Exception.Message
    Add-Content -Path $logFile -Value "$(Get-Date): $errorMessage"
    Write-Host "An error occurred. Check the log file for details: $logFile" -ForegroundColor Red
    exit 1
}
# Indicate that the script execution is complete
Write-Host "Script execution completed." -ForegroundColor Cyan
