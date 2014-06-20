require "yaml"
require "fileutils"
require "language_pack/package_fetcher"
require "language_pack/format_duration"
require 'fileutils'
require "language_pack/java"

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
    def buildpack_cache_dir
      @cache_path || "/var/vcap/packages/buildpack_cache"
    end
    def compile
      Dir.chdir(@build_path) do
       
        install_geronimo
        #modify_web_xml
      end
    end
   
    def install_geronimo
       
       #puts geronimo_package
       geronimo_package = geronimo_config["repository_root"]
       filename = geronimo_config["filename"]
        FileUtils.mkdir_p geronimo_dir
      geronimo_zip="#{geronimo_dir}/geronimo.zip"
       puts "------->Downloading #{filename}  from #{geronimo_package}"
       download_start_time = Time.now
       system("curl #{geronimo_package}/#{filename} -s -o #{geronimo_zip}")
       puts "(#{(Time.now - download_start_time).duration})"
       puts "------->Unpacking Geronimo"
       download_start_time = Time.now
       #system "unzip -oq -d #{geronimo_zip} #{geronimo_dir} 2>&1"
       run_with_err_output("unzip -oq -d #{geronimo_dir} #{geronimo_zip} && mv #{geronimo_dir}/geronimo-tomcat*/* #{geronimo_dir} && " +
              "rm -rf #{geronimo_dir}/geronimo-tomcat*")
       puts "(#{(Time.now - download_start_time).duration})"
        if File.exists?("#{geronimo_dir}/bin/geronimo.sh")
        puts "Retrieved Geronimo"
      else
         puts "unable to Retrieve Geronimo"
        exit 1
      end
       
    end
   
    
     def geronimo_config
      YAML.load_file(File.expand_path(GERONIMO_CONFIG))
    end
     def geronimo_dir
      ".geronimo"
    end
    def release
      {
          "addons" => [],
          "config_vars" => {},
          "default_process_types" => default_process_types
      }.to_yaml
    end
     def default_process_types
      {
        "web" => "./bin/geronimo.sh run"
      }
    end
     def run_with_err_output(command)
      %x{ #{command} 2>&1 }
    end
    
  end
end
