require "yaml"
require "fileutils"
require "language_pack/package_fetcher"
require "language_pack/format_duration"

module LanguagePack
  class Geronimo
    
    include LanguagePack::PackageFetcher
    DEFAULT_JD
    
    

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
        install_java
        
        
        setup_profiled
      end
    end

