require "yaml"
require "fileutils"
require "language_pack/package_fetcher"
require "language_pack/format_duration"

module LanguagePack
  class Geronimo
    
    
    
    
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
        modify_web_xml
      end
    end
   
    def install_geronimo
       geronimo_package = geronimo_config["repository_root"]
       puts geronimo_package
    end
    
     def geronimo_config
      YAML.load_file(File.expand_path(GERONIMO_CONFIG))
    end
    
  end
end
