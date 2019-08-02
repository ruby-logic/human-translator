# Gem's configuration
module HumanTranslator
  # Configuration class
  class Config

    def config
      YAML.load_file(config_file).freeze
    end

    private

    def config_path
      File.join(Dir.pwd, 'config/human_translator.yml')
    end

    def config_file
      return config_path if File.exist?(config_path)

      File.join(
        File.dirname(__FILE__),
        '..',
        '..',
        'example',
        'himan_translator.yml'
      )
    end

  end
end
