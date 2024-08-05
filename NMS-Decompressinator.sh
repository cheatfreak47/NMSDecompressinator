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

# Store the original directory
original_dir=$(pwd)

# Create working directory
working_dir="$HOME/nms_working_folder"
mkdir -p "$working_dir"

# Check if psarc.exe and NMSResign.exe exist in the current directory
if [ ! -f psarc.exe ] || [ ! -f NMSResign.exe ]; then
    echo "Error: psarc.exe or NMSResign.exe not found in the current directory."
    echo "Please put this script, psarc.exe, and NMSResign.exe in the No Man's Sky/GAMEDATA/PCBANKS folder."
    echo "Press any key to exit."
    read -n 1 -s
    exit 1
fi

# Move psarc.exe and NMSResign.exe to working directory
mv psarc.exe NMSResign.exe "$working_dir/"

# Move .pak files to working directory
pak_files=(*.pak)
if [ ${#pak_files[@]} -eq 0 ]; then
    echo "Error: No .pak files found in the current directory."
    echo "Please put this script in the No Man's Sky/GAMEDATA/PCBANKS folder."
    echo "Press any key to exit."
    read -n 1 -s
    exit 1
fi
mv *.pak "$working_dir/"

# Move BankSignatures.bin and timestamp.txt if they exist
[ -f BankSignatures.bin ] && mv BankSignatures.bin "$working_dir/"
[ -f timestamp.txt ] && mv timestamp.txt "$working_dir/"

# Change to working directory
cd "$working_dir" || exit 1

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

# Backup BankSignatures
if [ -f "BankSignatures.bin" ] && [ "$noBackup" = false ]; then
    echo "Backing up BankSignatures.bin"
    cp -f "BankSignatures.bin" PackedFileBackup/
fi

# Make New BankSignatures
wine NMSResign.exe -createbin

# Write the current timestamp to the file
date "+%Y-%m-%d %H:%M:%S" > timestamp.txt

# Move processed files back to original directory
mv -f * "$original_dir/"

# Change back to original directory
cd "$original_dir"

# Clean up working directory
rm -rf "$working_dir"

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
