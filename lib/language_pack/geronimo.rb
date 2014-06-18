require "yaml"
require "fileutils"
require "language_pack/package_fetcher"
require "language_pack/format_duration"
require 'fileutils'

module LanguagePack
  class Geronimo
    
    
    
    include LanguagePack::PackageFetcher
    GERONIMO_CONFIG = File.join(File.dirname(__FILE__), "../../config/geronimo.yml")
    attr_reader :build_path, :cache_path

    # changes directory to the build_path
    # @param [String] the path of the build dir
    # @param [String] the path of the cache dir
    def initialize(build_path, cache_path=nil)
      @build_path = build_path
      @cache_path = cache_path
    end
    
    def compile
      Dir.chdir(@build_path) do
        install_geronimo
        #modify_web_xml
      end
    end
   
    def install_geronimo
       geronimo_package = geronimo_config["repository_root"]
       filename = geronimo_config["filename"]
       #puts geronimo_package
       puts "------->Downloading #{filename}  from #{geronimo_package}"
       download_start_time = Time.now
       system("curl #{geronimo_package}/#{filename} -s -o #{filename}")
       puts "(#{(Time.now - download_start_time).duration})"
       puts "------->Unpacking Geronimo"
       download_start_time = Time.now
       system "unzip -o #{filename} -d #{@build_dir}  2>&1"
       #unzip -o \"#{archive}/*\" -d \"#{destination_folder}\
       puts "(#{(Time.now - download_start_time).duration})"
       
       
    end
    
     def geronimo_config
      YAML.load_file(File.expand_path(GERONIMO_CONFIG))
    end
    
  end
end
