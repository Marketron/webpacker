require "yaml"
require "active_support/core_ext/hash/keys"
require "active_support/core_ext/hash/indifferent_access"

class Webpacker::Configuration
  attr_reader :root_path, :config_path, :env

  def initialize(root_path:, config_path:, env:)
    @root_path = root_path
    @config_path = config_path
    @env = env
  end

  def dev_server
    fetch(:dev_server)
  end

  def compile?
    fetch(:compile)
  end

  def source_path
    root_path.join(fetch(:source_path))
  end

  def additional_paths
    fetch(:additional_paths)
  end

  def source_entry_path
    source_path.join(fetch(:source_entry_path))
  end

  def public_path
    root_path.join(fetch(:public_root_path))
  end

  def public_output_path
    public_path.join(fetch(:public_output_path))
  end

  def public_manifest_path
    public_output_path.join("manifest.json")
  end

  def cache_manifest?
    fetch(:cache_manifest)
  end

  def cache_path
    root_path.join(fetch(:cache_path))
  end

  def check_yarn_integrity=(value)
    warn <<~EOS
      Webpacker::Configuration#check_yarn_integrity=(value) is obsolete. The integrity
      check has been removed from Webpacker (https://github.com/rails/webpacker/pull/2518)
      so changing this setting will have no effect.
    EOS
  end

  def webpack_compile_output?
    fetch(:webpack_compile_output)
  end

  private
    def fetch(key)
      data.fetch(key, defaults[key])
    end

    def data
      @data ||= load
    end

    def load
      YAML.load(config_path.read, aliases: true)[env].deep_symbolize_keys

    rescue Errno::ENOENT => e
      raise "Webpacker configuration file not found #{config_path}. " \
            "Please run rails webpacker:install " \
            "Error: #{e.message}"

    rescue Psych::SyntaxError => e
      raise "YAML syntax error occurred while parsing #{config_path}. " \
            "Please note that YAML must be consistently indented using spaces. Tabs are not allowed. " \
            "Error: #{e.message}"
    end

    def defaults
      @defaults ||= \
        HashWithIndifferentAccess.new(YAML.load_file(File.expand_path("../../install/config/webpacker.yml", __FILE__), aliases: true)[env])
    end
end
