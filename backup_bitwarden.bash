#!/bin/bash

# Set Variables
email='seegal.panchal@caseware.com'
now=$(date +"%Y-%m-%d")

# Read Password
read -s -p "Password: " password

# Login to Bitwarden
bw login $email $password
session=$(bw unlock --raw $password)
bw sync --session $session

# Sync and export Bitwarden Files
bw export $password --session $session --format csv --raw | gpg --passphrase "$password" --batch --yes -c -o csv_$now.csv.gpg
bw export $password --session $session --format json --raw | gpg --passphrase "$password" --batch --yes -c -o json_$now.json.gpg

# Upload to Google Drive
curl -X POST -L \
    -H "Authorization: Bearer `cat /tmp/token.txt`" \
    -F "metadata={name : 'backup.zip'};type=application/json;charset=UTF-8" \
    -F "file=@backup.zip;type=application/zip" \
    "https://www.googleapis.com/upload/drive/v3/files?uploadType=multipart"