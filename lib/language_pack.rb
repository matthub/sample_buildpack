require "language_pack/java"
require "language_pack/geronimo"

# General Language Pack module
module LanguagePack

  # detects which language pack to use
  # @param [Array] first argument is a String of the build directory
  # @return [LanguagePack] the {LanguagePack} detected
  def self.compile(*args)
    Dir.chdir(args.first)
    Java.compile(*args)
   # Geronimo.compile(*args)
    
  end

end
