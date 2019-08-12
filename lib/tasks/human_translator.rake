require 'xlsxtream'
require File.expand_path('rake_classes/human_translator_task', __dir__)

namespace :human_translator do
  task generate_missing: :environment do
    HumanTranslatorTask.new(only_missing: true).generate_translation_files
  end

  task generate_all: :environment do
    HumanTranslatorTask.new(only_missing: false).generate_translation_files
  end

  task import_all: :environment do
    HumanTranslatorTask.new(only_missing: false).import_translation_files
  end
end
