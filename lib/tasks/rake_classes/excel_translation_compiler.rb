require File.expand_path('translation_yaml_helper', __dir__)

# This class handler creation of excel translations files.
class ExcelTranslationCompiler

  def initialize(config:, write_manual:, only_missing:, base_path:)
    @write_manual = write_manual
    @config = config
    @base_language = config['base_language']
    @only_missing = only_missing
    @base_path = base_path
  end

  def create_xlsx(language_structs, out_path)
    return if language_structs.empty?

    initialize_exports_directory

    Xlsxtream::Workbook.open(out_path) do |file|
      write_manual_to_xlsx(file, language_structs.length) if write_manual
      write_tabs_to_xlsx(file, language_structs)
    end
  end

  private

  attr_accessor :only_missing, :base_language, :config, :write_manual,
                :base_path

  def write_manual_to_xlsx(file, xlsx_tabs_count)
    file.write_worksheet('MANUAL') do |sheet|
      sheet << config['manual']['headers']
      config['manual']['content'].each do |manual_line|
        sheet << variable_aware_manual(manual_line, xlsx_tabs_count)
      end
    end
  end

  def variable_aware_manual(manual_line, xlsx_tabs_count)
    manual_line.tap do |cell|
      cell[0].gsub!('NUM_OF_TOTAL_TABS', "#{xlsx_tabs_count.to_i + 1} ")
      cell[0].gsub!('NUM_OF_TOTAL_TABS_MINUS_ONE', xlsx_tabs_count.to_s)
    end
  end

  def write_tabs_to_xlsx(file, language_structs)
    language_structs.each do |language_struct|
      yaml_helper = TranslationYamlHelper.new(
        language_struct,
        only_missing: only_missing,
        base_language: base_language,
        base_path: base_path,
        config: config
      )
      write_tab(file, tab_name(language_struct), yaml_helper.translation_rows)
    end
  end

  def write_tab(file, tab_name, translation_rows)
    file.write_worksheet(tab_name) do |sheet|
      sheet << header_columns
      translation_rows.each { |row| sheet << row }
    end
  end

  def header_columns
    [
      base_language.upcase,
      'Your language',
      'Translation key - IGNORE THIS COLUMN! DO NOT REMOVE IT!'
    ]
  end

  def tab_name(language_struct)
    [
      language_struct.index,
      '-',
      File.basename(
        language_struct.basename,
        ".#{language_struct.language}.yml"
      )
    ].join(' ')
  end

  def initialize_exports_directory
    exports_directory = Rails.root.join('vendor', 'human_translations')
    return if File.exist?(exports_directory)

    FileUtils.mkdir_p(exports_directory)
  end

end
