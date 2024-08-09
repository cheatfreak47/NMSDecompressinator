### No Man's Sky Decompressinator

Decompressinator is a batch script that uses [PSARC](https://www.psdevwiki.com/ps3/PlayStation_archive_(PSARC)#PSARC) (Sony PlayStation SDK Tool) and [NMSResign](https://github.com/cheatfreak47/NMSResign) to automatically process the game `.pak` files by unpacking them and repacking with compression disabled. 

This, in most cases, will significantly improve game performance by eliminating CPU spikes caused by on-the-fly `.pak` decompression **without** running the game files *fully* unpacked, which is another method that itself introduces significantly longer loading times due to the file system strain caused by the game needing to open handles to thousands of files.

In most cases, it completely eliminates commonly experienced lag spikes when leaving the atmosphere of a planet, calling in freighters, and many other similar lag spikes that occur when the game needs to decompress data from a `.pak` file during gameplay. It may also improve loading times more generally, such as when loading into a save file, warping from system to system, or using teleporters. Because it addresses these lag spikes, other similar mods that also address these things are rendered moot by using this, so adjust your mods folders accordingly.

So, how and why does this work?

Basically, this improvement happens because decompressing and repacking the files as is, you are dropping the requirement for the game to spend CPU cycles on decompression during any loading situation, and are instead relying on your disk's raw read speed to get the necessary files instead. Decompressed `.pak` files are much larger than compressed `.pak` files, so **it's highly recommended you store No Man's Sky on a very fast reading disk, such as any decent quality SSD from a reputable brand**. Extremely poor quality/no-name brand SSDs and slow or fragmented mechanical hard disks may actually see performance losses in some cases if this script is used, since the reason the performance gains occur depends on having fast file access to begin with. Because of this, the amount of improvement this has on performance is variable from computer to computer, but assuming you are running the game from any even half-decent SSD, even older SATA ones, it should improve performance and reduce lag spikes as intended.

Obviously this performance boost comes at the cost of storage space. Uncompressing the files will roughly triple the amount of required storage space. As of No Man's Sky Worlds Part 1, assuming you delete the backup of the compressed files afterwards or ran with the `-no-backup` argument, the game takes up **~44.8GB** of storage total.

#### Features:
 - Works on all No Man's Sky versions, *theoretically* including all future updates.
 - Doesn't conflict with any mods that load through the typical mod loading mechanisms.
 - Tries to be smart about running again after No Man's Sky updates or branch switches by checking file timestamps. (Can be bypassed using `-force`.)
 - Backs up the base game files in a sub folder in case things go wrong. (Can be bypassed by using `-no-backup`, which also slightly reduces the required free space footprint during runtime by a bit.)
 - Disables the "File Tampering" warning by using NMSResign to generate `BankSignatures.bin`.
 
#### Usage:
1. Download and Extract the [latest release.](https://github.com/cheatfreak47/NMSDecompressinator/releases/latest) NexusMods Mirror available [here](https://www.nexusmods.com/nomanssky/mods/3126).
1. Copy `NMS-Decompressinator.bat`, `psarc.exe`, and `NMSResign.exe` over to your `No Man's Sky\GAMEDATA\PCBANKS` folder.
1. Ensure you have sufficient free space. As of No Man's Sky Worlds Part 1, the uncompressed `.pak` files will consume **44.7GB** of additional storage.
1. Run the `NMS-Decompressinator.bat`.
1. Wait patiently. This takes quite a while to run. You will see a completion message when it is done.
1. Test the game and make sure it works.
1. (Optional) Delete `PackedFileBackup` folder to reclaim the storage space that the original packed files take up.

After updates or changing beta branches, you may see a "File Tampering" warning upon starting up No Man's Sky. You can simply run the script again anytime to unpack the updated files and get rid of the Tamper warning. Running the game without rerunning the script shouldn't cause any problems, but it's definitely recommended you run the script again after updates, since updates will cause the .pak files to become stock compressed ones again whenever they are updated.

Subsequent runs of the script should also be faster, as it tries to skip files that haven't been updated by checking file timestamps. This behavior can be bypassed using the `-force` argument.

Happy Exploring Travelers!

<!--
#### Technical Info and Source Code:
﻿NMS-Decompressinator uses the official PSARC (same version bundled in [PsArcTool](https://github.com/periander/PSArcTool/tree/master/PSArcTool/Resources)) and an open source [fork of NMSResign](https://github.com/cheatfreak47/NMSResign)﻿ to accomplish it's goals. The script is written in batch, and is fairly well commented. I have a [Github Repo](https://github.com/cheatfreak47/NMSDecompressinator) as well, if anyone would like to contribute or read the script directly in the browser. The script itself is licensed as Public Domain under WTFPL. NMSResign's code is licensed GPL-3.0.

Are you a Linux user? There's also [a bash script on the GitHub](https://github.com/cheatfreak47/NMSDecompressinator/blob/main/NMS-Decompressinator.sh) that uses Wine to run the same operations on Linux. Simply download the bash script directly from the repo, and grab the latest release to get the required windows executables.
-->

#### Problems or Bugs?

If you think you've found a bug, run into some sort of problem, or otherwise need some sort of help, feel free to submit an issue or post a comment in one of the following places (in order of my preference):
 - Ping @cheatfreak in **#modding** on the [Official No Man's Sky Discord](https://discord.com/invite/nomanssky)
 - [NexusMods Comment Section](https://www.nexusmods.com/nomanssky/mods/3126?tab=posts)
 - [Github Issue Tracker](https://github.com/cheatfreak47/NMSDecompressinator/issues)
 - [NexusMods Bug Tracker](https://www.nexusmods.com/nomanssky/mods/3126?tab=bugs)