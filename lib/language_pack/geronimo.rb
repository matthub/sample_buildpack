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
        geronimo_package = geronimo_config["repository_root"]
       filename = geronimo_config["filename"]
        fetch_from_buildpack_cache(geronimo_package,filename)||
        fetch_from_curl(geronimo_package,filename)
        #modify_web_xml
      end
    end
   
    def fetch_from_curl(geronimo_package,filename)
       
       #puts geronimo_package
       puts "------->Downloading #{filename}  from #{geronimo_package}"
       download_start_time = Time.now
       system("curl #{geronimo_package}/#{filename} -s -o #{filename}")
       puts "(#{(Time.now - download_start_time).duration})"
       puts "------->Unpacking Geronimo"
       download_start_time = Time.now
       system "unzip  file #{filename} -d #{@build_path}"
        #system "unzip -oq -d #{@build_dir} #{filename} 2>&1"
       #unzip -o \"#{archive}/*\" -d \"#{destination_folder}\
       puts "(#{(Time.now - download_start_time).duration})"
       
       
    end
    def fetch_from_buildpack_cache(geronimo_package,filename)
      file_path = File.join(@cache_path, filename)
      return unless File.exist?(file_path)
      puts "------>Copying #{filename} from the buildpack cache ..."
      FileUtils.cp(file_path, ".")
      File.expand_path(File.join(".", filename))
    end
    
     def geronimo_config
      YAML.load_file(File.expand_path(GERONIMO_CONFIG))
    end
    
  end
end
