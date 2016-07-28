# mcfpm
A Minecraft Forge Package Manager.

MCFPM is a simple package manager used to handle mod and modpack installations easily and lightly.
Mods are stored in a ~/.mcfpm/mods folder, and modpacks are stored in ~/.mcfpm/packs as JSONs and folders containing overrides, as per CurseForge modpack standards go.

Packages are loaded into the game through the JSON file, and the MCFPM Loader mod. See that repository for details.

This package manager was designed similarly to RubyGems, with similarly named commands.

## Usage
To use this, you can either clone the repository and use bin/mcfpm, or install it through RubyGems, which includes an executable.

(RubyGem currently not available. Coming soon.)

### Commands
#### fetch
The `mcfpm fetch <package>` command downloads a single package from CurseForge into the current working directory.
It takes a single argument, `package`, which is the project name shim.

#### installmod
The `mcfpm installmod <project name>` command installs a single mod into the mcfpm directory.

#### installpack
The `mcfpm installpack <project name>` command installs a single modpack and all of its mods into the mcfpm directory.
Additionally, it will generate the JSON needed by MCFPM Loader to load all of the mods.

### manifest
`mcfpm manifest <zip>` Installs all of the files from the provided zip's manifest.json files into the current directory.

## TODO
* update command
* outdated
* uninstall
* id command
  * Get the project ID for the named package
    * Why?
