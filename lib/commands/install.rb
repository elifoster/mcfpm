require 'open-uri'
require 'zip'
require 'oj'
require 'net/http'
require 'fileutils'
require 'open_uri_redirections'
require_relative '../mcfpm'

# All of the main "install" commands: currently, installmod and installpack, used to install mods and modpacks to the
# central directory, for use by the mcfpm mod (coming soon).
class CommandInstall
  # Runs the installmod core functionality, installing a mod to the central mod directory (~/mcfpm/mods).
  # @param package [String] The package name.
  # @return [String] The returned response for output to the terminal.
  def self.run_mod(package)
    filename = run(package, MCFPM::MOD_DIR)
    return "Downloaded #{filename} mod to central directory."
  end

  def self.run_from_manifest(pack_zip, out_dir)
    manifest = {}
    Zip::File.open(pack_zip) do |zip|
      # noinspection RubyResolve
      manifest = Oj.load(zip.get_entry('manifest.json').get_input_stream.read)
    end

    mods = []
    manifest['files'].each do |hash|
      project_id = hash['projectID']
      uri = URI("http://minecraft.curseforge.com/projects/#{project_id}?cookieTest=1")
      project_name = Net::HTTP.get_response(uri)['Location'].split('/')[-1]
      file = run(project_name, out_dir)
      if file
        mods << file
        puts "Downloaded #{file} mod to #{out_dir}.\n"
      end
    end
    return mods
  end

  # Runs the installpack core functionality, downloading a pack (mcfpm/pack) and installing its mods.
  # @see run_mod
  # @param package [String] The modpack package name.
  # @return [String] The returned response for output to the terminal.
  def self.run_pack(package)
    filename = run(package, MCFPM::PACK_DIR)
    puts "Downloaded #{filename} modpack to central directory. Unpacking...\n"

    mods = run_from_manifest("#{MCFPM::PACK_DIR}/#{filename}", MCFPM::PACK_DIR)

    folder = File.basename(filename, File.extname(filename))

    Dir.foreach("#{MCFPM::PACK_DIR}/#{folder}/overrides/mods") do |item|
      next if item == '.' || item == '..'

      ary_file = item.split('.')
      # Just in case it has modified code.
      ary_file.insert(-2, "-#{package}-override.")
      new_item = ary_file.join
      FileUtils.mv("#{MCFPM::PACK_DIR}/#{folder}/overrides/mods/#{item}", "#{MCFPM::MOD_DIR}/#{new_item}")
      mods << new_item
      puts "Moved override #{item} to #{new_item}."
    end

    File.open("#{MCFPM::PACK_DIR}/#{package}.json", 'w') do |f|
      f.write(Oj.dump(mods))
    end

    manifest_file = "#{MCFPM::PACK_DIR}/#{folder}/manifest.json"
    modlist_file = "#{MCFPM::PACK_DIR}/#{folder}/modlist.html"
    mod_folder = "#{MCFPM::PACK_DIR}/#{folder}/overrides/mods"
    zip_file = "#{MCFPM::PACK_DIR}/#{filename}"
    File.delete(manifest_file) if File.file?(manifest_file)
    File.delete(modlist_file) if File.file?(modlist_file)
    File.delete(mod_folder) if File.directory?(mod_folder)
    File.delete(zip_file) if File.file?(zip_file)

    FileUtils.mv("#{MCFPM::PACK_DIR}/#{folder}", "#{MCFPM::PACK_DIR}/#{package}")

    return "Finished downloading #{package} modpack and its dependencies."
  end

  private

  # Downloads and overrides the package.
  # @param package [String] The package name shim (example seedcopy or super-modded-insanity).
  # @param directory [String] The directory to install (MOD_DIR or PACK_DIR).
  # @return [String] The filename.
  # @return [NilClass] When it cannot find the project at all, it returns nil.
  def self.run(package, directory)
    uri = URI("http://minecraft.curseforge.com/projects/#{package}/files/latest?cookieTest=1&filter-game-version=2020709689%3A4449")
    response = Net::HTTP.get_response(uri)
    if response.is_a?(Net::HTTPNotFound)
      puts "WARNING: Could not find #{package} on CurseForge. Skipping..."
      return nil
    end

    location = response['Location']
    encoded_location = URI.encode(location, '[]')
    new_uri = URI(encoded_location)
    filename = location.split('/')[-1]
    full_path = "#{directory}/#{filename}"
    # Reinstall packages. Consider adding an option to disable this functionality.
    File.delete(full_path) if File.file?(full_path)

    # Blame CoFHCore.
    begin
      IO.copy_stream(open(new_uri, allow_redirections: :all), full_path)
    rescue OpenURI::HTTPError
      first_uri = URI(URI.encode(Net::HTTP.get_response(new_uri)['Location'], '[]'))
      IO.copy_stream(open(first_uri, allow_redirections: :all), full_path)
    end
    return filename
  end
end
