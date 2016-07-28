require 'open-uri'
require 'net/http'

# The command for installing a package to the current working directory.
class CommandFetch
  # Runs the fetch command's functionality, installing a package to the curretn working directory.
  # @param package [String] The package name.
  # @return [String] The response for output in the terminal.
  def self.run(package)
    # This URL was obtained from the anatai/minecraft-curse-mods repository.
    uri = URI("http://minecraft.curseforge.com/projects/#{package}/files/latest?cookieTest=1&filter-game-version=2020709689%3A4449")
    filename = Net::HTTP.get_response(uri)['Location'].split('/')[-1]
    full_path = "#{Dir.pwd}/#{filename}"
    ret = ''
    if File.file?(full_path)
      ret << "WARNING: ALREADY PRESENT IN WORKING DIRECTORY. REPLACING.\n\n"
      File.delete(full_path)
    end
    IO.copy_stream(open(url), full_path)
    ret << "Downloaded #{filename} to current directory (#{Dir.pwd})."
    return ret
  end
end