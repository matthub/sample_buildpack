require "net/http"
require "uri"
require "base64"

module LanguagePack
  class PackageFetcher

    VENDOR_URL = "https://s3.amazonaws.com/heroku-jvm-langpack-java"
    PACKAGES_CONFIG = File.join(File.dirname(__FILE__), "../../config/packages.yml")

    attr_writer :buildpack_cache_dir

    def buildpack_cache_dir
      @buildpack_cache_dir || "/var/vcap/packages/buildpack_cache"
    end

    def fetch_jdk_package(version)
      jdk_package = packages_config["openjdk"].find { |p| p["version"] == version }

      raise "Unsupported Java version: #{version}" unless jdk_package

      fetch_from_buildpack_cache(jdk_package["jre"]) ||
      fetch_from_curl(jdk_package["full"], VENDOR_URL)
    end

    

    def fetch_package_and_untar(filename, url=VENDOR_URL)
      fetch_package(filename, url) && run("tar xzf #{filename}")
    end

    def packages_config
      YAML.load_file(File.expand_path(PACKAGES_CONFIG))
    end

    private

    def fetch_from_buildpack_cache(filename)
      file_path = File.join(buildpack_cache_dir, filename)
      return unless File.exist?(file_path)
      puts "Copying #{filename} from the buildpack cache ..."
      FileUtils.cp(file_path, ".")
      File.expand_path(File.join(".", filename))
    end

   
    def fetch_from_curl(filename, url)
      puts "Downloading #{filename} from #{url} ..."
      system("curl #{url}/#{filename} -s -o #{filename}")
      File.exist?(filename) ? filename : nil
    end

    def file_checksum(filename)
      Digest::SHA1.file(filename).hexdigest
    end
  end
end
