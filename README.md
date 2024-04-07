# Effortless hsdis

The repository provides an effortless way to build hsdis -- [the hotspot disassembly library](https://blogs.oracle.com/javamagazine/post/java-hotspot-hsdis-disassembler).

## Usage
```
git clone https://github.com/qwwdfsad/effortless-hsdis
cd effortless-hsdis  
cmake -B build . && cmake --build build --config Release  
```  

It will print something like
```  
...  
[100%] Linking C shared library hsdis-aarch64.dylib  
Path to hsdis: /Users/qwwdfsad/workspace/effortless-hsdis/build/hsdis-aarch64.dylib  
[100%] Built target hsdis  
```  
and you are good to go.

You'll need CMake and git on your machine, no other dependencies are required.

## How does it work and where are the sources

The project provides a [CmakeLists.txt](CMakeLists.txt) build file with no other third-party sources.

It checks out hsdis sources from the OpenJDK repository (right now -- [OpenJDK 21 release tag](https://github.com/openjdk/jdk21/releases/tag/jdk-21-ga))   
and [Capstone](https://github.com/capstone-engine/capstone) disasambler, builds one against the other and prints  
the path to the resulting hsdis that you can later put into the corresponding `$JAVA_HOME/lib/server/`, `/usr/lib` on Linux or just add it to the  `LD_LIBRARY_PATH`.

The cool part -- this repo controls no sources and takes it from the official repositories, thus relieving us from verifying that the sources/binaries are the original ones,
as well as updating them manually.

## Why can't you install hsdis for my Java

A few reasons:

* It's never a good idea to mess with the build environment outside of the confined build directory
* It's awkward to figure out what `Java` is on the machine. There is `$JAVA_HOME`, there are
 a multitude of versions nearby, and also a bunch of them come from SDKMAN in its own designated path.

Adding hsdis to `/usr/lib` on Linux or exporting it with `DYLD_LIBRARY_PATH` on OS X via `.zshrc` should do the trick, but it's up you, you'll figure this out.

## I want even more automated installation

Please wait a bit, I'll figure something out with brew and `.deb`.

## I don't want to build it at all

You can download hsdis from ~~internet strangers~~ the various community builds.
I was looking up to [chriswhocodes.com/hsdis](https://chriswhocodes.com/hsdis/) and [builds.shipilev.net/hsdis](https://builds.shipilev.net/hsdis/).
Be sure to read a disclaimer to these builds though.

## Does it work on Windows

I don't know. It should but I never bothered checking. If there is anybody on Windows and it doesn't work (or works!),
let me know and I'll add it to the README or fix the build.