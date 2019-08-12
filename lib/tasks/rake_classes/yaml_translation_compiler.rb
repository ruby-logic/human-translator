require File.expand_path('excel_translation_compiler', __dir__)

# This class generates yaml file out of excel translations file.
class YamlTranslationCompiler

  def initialize(only_missing:, config:, base_path:)
    @config = config
    @base_language = config['base_language']
    @only_missing = only_missing
    @base_path = base_path
  end

  def create_yaml(language_file, translation_struct)
    content = out_yaml_content(language_file, translation_struct)
    File.open(translation_struct.file, 'w+') do |f|
      f.write(content.to_yaml)
    end
  end

  private

  attr_accessor :only_missing, :config, :base_path

  def excel_compiler
    @excel_compiler ||= ExcelTranslationCompiler.new(
      only_missing: only_missing, config: config, write_manual: true,
      base_path: base_path
    )
  end

  def out_yaml_content(language_file, translation_struct)
    new = output_hash(spreadsheet_content(language_file, translation_struct))
    existing = Psych.load(File.open(translation_struct.file))
    existing.deep_merge(new)
  end

  def spreadsheet_content(xlsx_file, translation_struct)
    Roo::Spreadsheet.open(xlsx_file).sheet(
      excel_compiler.tab_name(translation_struct)
    )
  end

  def output_hash(sheet)
    @output_hash = {}

    (2..sheet.last_row).each do |row|
      create_hash(sheet, row) if value(sheet, row).present?
    end

    @output_hash
  end

  def value(sheet, row)
    sheet.cell(row, 'B')
  end

  def key_path(sheet, row)
    sheet.cell(row, 'C').split(':')
  end

  def create_hash(sheet, row)
    keys = key_path(sheet, row)
    last_key = keys.pop(1)
    hash = Hash.new { |h, k| h[k] = Hash.new(&h.default_proc) }

    keys.inject(hash) { |h, k| h[k] }[last_key.first] = value(sheet, row)

    @output_hash = @output_hash.deep_merge(hash)
  end

end
