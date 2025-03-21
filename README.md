# playwright-manual-browser-downloader

# Playwright Browser Installation Script

## Overview
This project contains a PowerShell script (`installbrowsers.ps1`) designed to manually install the required browsers for Playwright testing. The script performs various tasks including checking for user input, downloading browser files, and managing installation directories.

## Files
- **installbrowsers.ps1**: A PowerShell script that installs Playwright browsers. It checks for the `--all` argument, executes a Playwright command to gather browser information, prompts the user for installation confirmation, creates necessary directories, downloads ZIP files of the browsers, extracts them, and cleans up the ZIP files afterward.

## Usage Instructions
1. **Prerequisites**:
   - Ensure you have PowerShell installed on your system.
   - Install Node.js and npm to use the Playwright CLI.
   - Ensure you have the necessary permissions to create directories and download files.

2. **Running the Script**:
   - Open PowerShell.
   - Navigate to the directory containing the `installbrowsers.ps1` script.
   - Run the script using the following command:
     ```
     .\installbrowsers.ps1
     ```
   - To install all browsers without confirmation, use:
     ```
     .\installbrowsers.ps1 --all
     ```

3. **Script Functionality**:
   - The script performs a dry run of the Playwright installation to gather browser information.
   - It prompts the user for confirmation before installing each browser unless the `--all` option is specified.
   - It manages installation directories, downloads browser ZIP files, extracts them, and cleans up afterward.

## Logging
- The script logs any errors encountered during execution to `installbrowsers.log`. Check this file for details if an error occurs.

## Conclusion
This script simplifies the process of installing browsers required for Playwright testing, providing a user-friendly interface for managing browser installations.
