### NMS-Decompressinator.bat (Windows Batch Script)
This script exists for a few reasons:
 - No Man's Sky has a lot of lag when loading, and it loads often.
 - Running the game Unpacked causes File System Access Bottlenecks, slowing loading down, so it is an inadequate solution.
 - It's possible to run the game uncompressed but still packed.

So I made a script that automatically repacks the game uncompressed but still packed, which allows you to negate decompression-caused CPU spikes while the game is loading. It expands the footprint of the game files though, of course (As of ADRIFT, it goes from ~14GB to ~40GB). It requires [PSARC](https://www.psdevwiki.com/ps3/PlayStation_archive_(PSARC)#PSARC) (Sony PlayStation SDK Tool) and [NMSResign Fork](https://github.com/cheatfreak47/NMSResign).

It has the following features:
 - Works on all No Man's Sky versions.
 - Backs up the base game files in a sub folder in case things go wrong.
 
Details and release version can be found [here](https://github.com/cheatfreak47/NMSDecompressinator/releases/latest), and the official release page and full technical explanation can be found [here](https://nomansskyretro.com/wiki/Decompressinator).