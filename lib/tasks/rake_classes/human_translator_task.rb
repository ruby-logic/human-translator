require File.expand_path('translations_list_builder', __dir__)
require File.expand_path('excel_translation_compiler', __dir__)

# This class coordinates translations export process.
class HumanTranslatorTask

  def initialize(only_missing:)
    @base_path = Rails.root.join('config', 'locales')
    @write_manual = true
    @only_missing = only_missing
  end

  def generate_translation_files
    logger = Logger.new(STDOUT)

    builder.language_directories.each do |dir|
      dir_basename = File.basename(dir)
      logger.info "Processing #{dir_basename}"
      excel_compiler.create_xlsx(
        builder.language_structs(dir_basename),
        out_path(language: dir_basename)
      )
      logger.info "Finished processing #{dir_basename}"
    end
  end

  private

  attr_accessor :write_manual, :base_path, :only_missing

  def config
    @config ||= HumanTranslator::Config.new.config
  end

  def builder
    @builder ||= TranslationListBuilder.new(
      only_missing: only_missing, config: config, base_path: base_path
    )
  end

  def excel_compiler
    @excel_compiler ||= ExcelTranslationCompiler.new(
      only_missing: only_missing, config: config, write_manual: write_manual,
      base_path: base_path
    )
  end

  def out_path(language:)
    Rails.root.join('vendor', 'human_translations', [language, '.xlsx'].join)
  end

end
