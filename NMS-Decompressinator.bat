:: No Man's Sky Decompressinator-F Script by CheatFreak

:: This is a batch file that will systematically decompress (unpack and repack uncompressed) No Man's Sky PAK files. 
:: It requires the PS3 SDK PSARC Tool either in the same folder as this batch file or placed somewhere on the PATH Environment Variable.
:: You can get the PS3 SDK PSARC Tool from from archive.org or dig it out of your dev files if you were a PS3 Dev. 
:: I make no claims about the legality of doing so, though I very much doubt Sony cares about an SDK tool from over a decade ago. 
:: You can find it here. (https://archive.org/download/ps3_sdks) in file "PS3 4.50 SDK-YLoD [450_001].7z". The required file is called psarc.exe.
:: It also requires my NMSResign fork (https://github.com/cheatfreak47/NMSResign). Original program by stk25.

:: ---------------------------------------------------------------------------------------------------------------------------------------------------------------

:: Running the game files uncompressed (but NOT unpacked) has significant performance benefits.
:: The game has to spend no time or CPU decompressing assets. Eliminates pesky lag spikes, such as the infamous ones when entering/exiting planet atmospheres. 
:: This performs better than running the game fully unpacked as well, since the game does not have to open 1000s of file handles to get the data.
:: The exact amount you will benefit from this depends largely on your rig.

:: To use, place psarc.exe and this batch file in install folder in \No Man's Sky\GAMEDATA\PCBANKS and run the batch file. It will take a while to run.
:: All your old compressed pack files will be moved into "PackedFileBackup".
:: After running, verify the game works properly for you. If it does, good! Feel free to delete the PackedFileBackup if all is well.

:: 	Any Drawbacks? 
::  	- the game takes up an assload more space- about 39GB or so, possibly more as the game keeps getting updated.
::  	- it breaks whenever the game updates. when it breaks, validate the cache. Delete the old backup folder, and run it again.
::  	- takes a while to run, depending on how slow your PC is.
@echo off

::ErrorChecks
if NOT exist "BankSignatures.bin" (
	goto :ErrorWrongDir
)
if NOT exist "psarc.exe" (
	goto :ErrorMissingFile 
)
if NOT exist "NMSResign.exe" (
	goto :ErrorMissingFile
)
if exist "PackedFileBackup" (
	goto :ErrorBackupFolder
)

echo NMS Decompressinator (Full) by CheatFreak
echo -----------------------------------------
echo it uses....
echo  psarc by Sony Computer Entertainment LLC
echo  NMSResign Fork by CheatFreak.
echo  Original NMSResign by emoose/stk25.
echo -----------------------------------------
echo Note: 
echo  It may seem at some points like it has
echo  stopped and isn't continuing...
echo  Don't worry, it's fine. Just patiently
echo  wait for it to finish. It takes time.
echo  Please do not interrupt the process.
echo -----------------------------------------
echo Beginning in...
timeout /t 1 > NUL
echo 5...
timeout /t 1 > NUL
echo 4...
timeout /t 1 > NUL
echo 3...
timeout /t 1 > NUL
echo 2...
timeout /t 1 > NUL
echo 1...
timeout /t 1 > NUL
cls
@echo on
::Make Backup Dir
mkdir "PackedFileBackup"
::Process .pak files one at a time using multiple operations to decompress them. 
::Extract, Backup, Repack Uncompressed, then Delete the Unpacked Folder, and move on to the next .pak till no more .paks remain.
for %%f in (*.pak) do (
	psarc.exe extract "%%f" --to="%%~nf"
	move /Y "%%~nxf" "PackedFileBackup"
	psarc.exe create -i "%%~nf" -N -y -o "%%~nxf" -s ".*?%%~nf"
	rmdir /s /q %%~nf
)
@echo off
::After all that, next we backup the stock BankSignatures.bin file.
copy /Y "BankSignatures.bin" "PackedFileBackup"
::Now we resign the BankSignatures.bin with the new files.
NMSResign.exe -createbin
echo  
echo  
echo  
echo Process complete!
echo -----------------------------------------
echo Enjoy a slightly less laggy No Man's Sky!
echo -----------------------------------------
echo Remember that if the game updates, this stops working and you will need to:
echo   1. Validate the game cache for No Man's Sky on Steam.
echo   2. Delete the old "PackedFileBackup" folder.
echo   3. Run this batch script again.
pause
exit

:ErrorWrongDir
echo You seem to be running the batch file from the wrong directory. 
echo After exiting, please put all files included in the download in the No Man's Sky install folder in GAMEDATA/PCBANKS.
pause
exit

:ErrorMissingFile
echo You seem to be missing the included psarc and NMSResign tools. Maybe you didn't copy them along with the batch file?
echo Please add those files from the download to the GAMEDATA/PCBANKS folder in your No Man's Sky install folder.
pause
exit

:ErrorBackupFolder
echo You seem to be running this program again after a previous run. 
echo Please move or delete the "PackedFileBackup" folder if you are sure that this is what you wanted to do, and run it again.
pause
exit