module HumanTranslator
  module Generators
    # This generator copies example config into config/.
    class InstallGenerator < Rails::Generators::Base

      source_root File.expand_path('../../../example', __dir__)

      def copy_config
        template 'human_translator.yml', 'config/human_translator.yml'
      end

    end
  end
end
