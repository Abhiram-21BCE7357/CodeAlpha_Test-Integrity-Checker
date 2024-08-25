# File Integrity Checker

A PowerShell script for monitoring file integrity by calculating and comparing file hashes. The script allows you to either collect a new baseline of file hashes or monitor existing files against a previously saved baseline to detect changes or deletions.

## Features

- **Collect Baseline:** Generate a hash baseline of all files in a specified directory and save it to a file.
- **Monitor Files:** Continuously monitor files in the specified directory and alert if any file is created, modified, or deleted compared to the baseline.

## Requirements

- PowerShell 5.1 or later
- Access to the directory you want to monitor

## Setup

1. **Clone the Repository:**

   ```bash
   git clone https://github.com/yourusername/file-integrity-checker.git
   cd file-integrity-checker

2. **Create Directory:**

   Ensure a Files directory exists in the same location as the script

   ```bash
   New-Item -Path "$PSScriptRoot\Files" -ItemType Directory


## Usage

1. **Collect a New Baseline:**

   Run the script and select option 'A' to collect a new baseline of file hashes.

   
3. **Monitor Files:**

   Run the script and select option 'B' to start monitoring files against the existing baseline


## Troubleshooting

- **Directory Not Found:** Ensure the 'F'iles directory exists at the specified path.
- **Permissions Issues:** Ensure you have the necessary permissions to read files and create/remove files in the script directory.
