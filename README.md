### No Man's Sky Decompressinator

A batch script that uses [PSARC](https://www.psdevwiki.com/ps3/PlayStation_archive_(PSARC)#PSARC) (Sony PlayStation SDK Tool) and [NMSResign](https://github.com/cheatfreak47/NMSResign) to automatically process the game `.pak` files by unpacking them and repacking with compression disabled to improve game performance by eliminating CPU spikes caused by on-the-fly `.pak` decompression **without** running the game fully unpacked, which introduces longer loading times due to the file system strain caused by the game needing to open handles to thousands of files.

The amount of improvement this has on performance is variable from PC to PC, but it should make a small difference even on high end machines. If nothing else, it addresses that commonly experienced lag spike when leaving the atmosphere of a planet, and other similar smaller lag spikes that occur during gameplay situations where data is loading, and should generally improve the loading times when loading into a save file, warping from system to system, or using teleporters. 

Full technical explanation can be found [here](https://nomansskyretro.com/wiki/Decompressinator).

#### Features:
 - Works on all No Man's Sky versions.
 - Tries to be smart about running again after No Man's Sky updates by checking file timestamps. (Can be bypassed using `-force`)
 - Backs up the base game files in a sub folder in case things go wrong. (Can be bypassed by using `-no-backup`)
 - Disables the "File Tampering" warning by using NMSResign to generate `BankSignatures.bin`.
 
#### Usage:
1. Download and Extract the [latest release.](https://github.com/cheatfreak47/NMSDecompressinator/releases/latest)
1. Copy `NMS-Decompressinator.bat`, `psarc.exe`, and `NMSResign.exe` over to your `No Man's Sky\GAMEDATA\PCBANKS` folder.
1. Run the `NMS-Decompressinator.bat`.
1. Wait patiently. This takes quite a while to run. You will see a completion message when it is done.
1. Test the game and make sure it works.
1. (Optional) Delete `PackedFileBackup` to reclaim the free space.
