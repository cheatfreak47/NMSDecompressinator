#!/bin/bash

# No Man's Sky Decompressinator Script by CheatFreak
# See https://github.com/cheatfreak47/NMSDecompressinator for details.
# It requires:
# PSARC by Sony Computer Entertainment LLC from any PlayStation SDK that includes it. (Bundled copy is from PS3 SDK 4.50)
# NMSResign 1.0.1 by stk25/emoose/CheatFreak from https://github.com/cheatfreak47/NMSResign

# Initialize argument variables
noBackup=false
force=false

# Check for arguments
for arg in "$@"; do
    case $arg in
        -no-backup)
            noBackup=true
            ;;
        -force)
            force=true
            ;;
    esac
done

# Check if any .pak files exist
if ! ls *.pak &> /dev/null; then
    echo "Error: No .pak files found in the working directory."
    echo "Please put this script, psarc.exe, and NMSResign.exe in the No Man's Sky/GAMEDATA/PCBANKS folder."
    echo "Press any key to exit."
    read -n 1 -s
    exit 1
fi

# Check if psarc.exe and NMSResign.exe exist
if [ ! -f psarc.exe ]; then
    echo "Error: psarc.exe not found in the working directory."
    echo "Please put this script, psarc.exe, and NMSResign.exe in the No Man's Sky/GAMEDATA/PCBANKS folder."
    echo "Press any key to exit."
    read -n 1 -s
    exit 1
fi
if [ ! -f NMSResign.exe ]; then
    echo "Error: NMSResign.exe not found in the working directory."
    echo "Please put this script, psarc.exe, and NMSResign.exe in the No Man's Sky/GAMEDATA/PCBANKS folder."
    echo "Press any key to exit."
    read -n 1 -s
    exit 1
fi

# Start Message
echo "NMS Decompressinator v2.0.0 by CheatFreak"
echo "-----------------------------------------"
echo "it uses...."
echo " psarc by Sony Computer Entertainment LLC"
echo "    (From PS3 SDK 4.50)"
echo " NMSResign Fork by CheatFreak"
echo "    (Original NMSResign by emoose/stk25.)"
echo "-----------------------------------------"
echo "Note: "
echo " It may seem at some points like it has"
echo " stopped and isn't continuing..."
echo " Don't worry, it's fine. Just patiently"
echo " wait for it to finish. It takes time."
echo "-----------------------------------------"
echo "Beginning in..."
sleep 1
echo "5..."
sleep 1
echo "4..."
sleep 1
echo "3..."
sleep 1
echo "2..."
sleep 1
echo "1..."
sleep 1

# Check if timestamp file exists and read it into a variable
if [ -f timestamp.txt ]; then
    lastTimestamp=$(cat timestamp.txt)
else
    lastTimestamp="1970-01-01 00:00:00"
fi

# Check if PackedFileBackup directory exists
if [ "$noBackup" = false ]; then
    mkdir -p PackedFileBackup
fi

# Loop over the files
for f in *.pak; do
    # Get the last write time of the current file
    fileTime=$(date -r "$f" "+%Y-%m-%d %H:%M:%S")

    # Compare the file time with the last timestamp
    isFileNewer=$(date -d "$fileTime" +%s)
    lastTimestampSeconds=$(date -d "$lastTimestamp" +%s)
    
    if [ "$force" = true ] || [ $isFileNewer -gt $lastTimestampSeconds ]; then
        wine psarc.exe extract "$f" --to="${f%.pak}"
        if [ "$noBackup" = true ]; then
            rm -f "$f"
        else
            mv -f "$f" PackedFileBackup/
        fi
        wine psarc.exe create -i "${f%.pak}" -N -y -o "$f" -s ".*?${f%.pak}"
        rm -rf "${f%.pak}"
    else
        echo "Skipping $f. Seems to be already unpacked, based on timestamp."
    fi
done

# Backup BankSignitures
if [ -f "BankSignatures.bin" ] && [ "$noBackup" = false ]; then
    echo "Backing up BankSignitures.bin"
    cp -f "BankSignatures.bin" PackedFileBackup/
fi

# Make New BankSignitures
wine NMSResign.exe -createbin

# Write the current timestamp to the file
date "+%Y-%m-%d %H:%M:%S" > timestamp.txt

# Exit Message
echo "Process complete!"
echo "-----------------------------------------"
echo "Enjoy a slightly less laggy No Man's Sky!"
echo "-----------------------------------------"
echo "After No Man's Sky updates, it is likely you will get a 'File Tampering' warning on launch."
echo "To fix this, just run the script again and it will decompress the updated files and resign."
echo "See ya next time..."
echo "Press any key to exit."
read -n 1 -s
