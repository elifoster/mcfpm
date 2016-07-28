require 'fileutils'
require_relative 'commands/fetch'
require_relative 'commands/install'

# Unfortunately, CurseForge is crap and doesn't handle KeepAlive's very well. So, we have to use the terrible Net::HTTP.

module MCFPM
  module_function

  HELP_TEXT = <<EOF
mcfpm is a package manager for Minecraft Forge. This is a
basic help message containing pointers to more information.

  Usage:
    mcfpm -h/--help
    mcfpm -v/--version

  Further help:
    mcfpm help commands       List all 'mcfpm' commands.
    mcfpm help <COMMAND>      Show help on COMMAND
                                (e.g. `mcfpm help update`)
EOF

  VERSION = '0.1.0'

  COMMANDS = <<EOF
MCFPM commands are:

  fetch            Download a package into the current directory.
  help             Provide help on the `mcfpm` command.
  installmod       Install a mod package.
  installpack      Install a modpack package.
  uninstallmod     Uninstall a mod package.
  uninstallpack    Uninstall a modpack package.
  manifest         Install a downloaded modpack from the manifest file into the current directory.
  update           Update a package.

For help on a particular command, use `mcfpm help COMMAND`
EOF

  UNKNOWN_COMMAND = 'WARNING: Unknown command %{command}. Try mcfpm help commands'

  HELP_COMMANDS = {
    help: 'Provide help on the `mcfpm` command',
    fetch: 'Downloads a package to the current working directory.',
    installmod: 'Installs a mod to the central directory.',
    installpack: 'Installs a modpack to the central directory.',
    manifest: 'Installs a modpack from the provided manifest.json into the current working directory.',
    commands: COMMANDS
  }

  # TODO Replace "mcfpm" with ".mcfpm" to hide it from users.
  MAIN_DIR = "#{Dir.home}/mcfpm"
  MOD_DIR = "#{MAIN_DIR}/mods"
  PACK_DIR = "#{MAIN_DIR}/packs"

  # Runs the mcfpm command.
  # @param args [Array<String>] ARGV.
  # @return [String] The command response.
  def run(args)
    safely_mkdir(MAIN_DIR)
    safely_mkdir(MOD_DIR)
    safely_mkdir(PACK_DIR)

    return HELP_TEXT if args.include?('-h') || args.include?('--help')
    return VERSION if args.include?('-v') || args.include?('--version')

    case args[0]
    when 'help'
      return HELP_COMMANDS[args[1].to_sym] if HELP_COMMANDS.key?(args[1].to_sym)
      return HELP_TEXT
    when 'fetch'
      return CommandFetch.run(args[1])
    when 'manifest'
      return CommandFetch.install_manifest(args[1])
    when 'installmod'
      return CommandInstall.run_mod(args[1])
    when 'installpack'
      return CommandInstall.run_pack(args[1]).to_s # remove
    else
    end
  end

  private

  # Makes a directory unless it already exists.
  # @param dir [String] The directory.
  # @return [void]
  def self.safely_mkdir(dir)
    Dir.mkdir(dir) unless File.directory?(dir)
  end
end
