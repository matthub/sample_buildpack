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
        copy_webapp_to_geronimo
        move_geronimo_to_root
        puts .var/config/config-substitutions.properties['HTTPPort']
        #.var/config/config-substitutions.properties[HTTPPort]=$PORT
      end
    end
   
    def install_geronimo
       
       #puts geronimo_package
       FileUtils.mkdir_p geronimo_home
       geronimo_package = geronimo_config["repository_root"]
       filename = geronimo_config["filename"]
       puts "------->Downloading #{filename}  from #{geronimo_package}"
       download_start_time = Time.now
       system("curl #{geronimo_package}/#{filename} -s -o #{filename}")
       puts "(#{(Time.now - download_start_time).duration})"
       puts "------->Unpacking Geronimo"
       download_start_time = Time.now
       system "unzip -oq -d #{geronimo_home} #{filename} 2>&1"
       run_with_err_output("mv #{geronimo_home}/geronimo-tomcat*/* #{geronimo_home} && " + "rm -rf #{geronimo_home}/geronimo-tomcat*")
       run_with_err_output("rm -rf geronimo.zip")
       puts "(#{(Time.now - download_start_time).duration})"
        
       unless File.exists?("#{geronimo_home}/bin/geronimo.sh")
         puts "Unable to retrieve Geronimo"
         exit 1
       end
      
    end
    def geronimo_config
      YAML.load_file(File.expand_path(GERONIMO_CONFIG))
    end
    def copy_webapp_to_geronimo
        run_with_err_output("mkdir -p #{geronimo_home}/deploy && mv * #{geronimo_home}/deploy")
    end
    def move_geronimo_to_root
      run_with_err_output("mv #{geronimo_home}/* . && rm -rf #{geronimo_home}")
    end
    def geronimo_home
      ".geronimo_home"
    end
    def app_home
      ".app_home"
    end
    def run_with_err_output(command)
      %x{ #{command} 2>&1 }
    end
   def bash_script
      <<-BASH
#!/bin/bash
export GERONIMO_OPTS="-Dorg.apache.geronimo.config.substitution.HTTPPort:$PORT"
BASH
    end
   
   
  end
end
