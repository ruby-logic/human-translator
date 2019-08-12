require File.expand_path('translations_list_builder', __dir__)
require File.expand_path('excel_translation_compiler', __dir__)

# This class simplifies access to XLSX files filled by the Human Translators.
class XlsxListBuilder

  def initialize(only_missing: false, config: nil, base_path: nil)
    @config = config
    @base_path = base_path
    @marker = config['missing_translation_marker']
    @only_missing = only_missing

    raise 'Marker is required - add it to config.' if @marker.nil?
  end

  def language_files
    initialize_imports_directory
    Dir.glob(Rails.root.join('vendor', 'imports', '*'))
  end

  def xlsx_import_structs(language_file)
    language_name = File.basename(language_file, '.xlsx')
    references = translation_references(
      language_file, translation_list_builder.language_structs(language_name)
    )
    return if references.nil?

    new_xlsx_import_struct(
      language_file: language_file,
      translation_structs: references
    )
  end

  private

  attr_accessor :config, :base_path, :marker, :only_missing

  def new_xlsx_import_struct(language_file:, translation_structs:)
    OpenStruct.new(
      language_file: language_file,
      translation_structs: translation_structs
    )
  end

  def translation_references(language_file, translation_structs)
    xlsx_sheets(xlsx_content(language_file)).map do |tab_name|
      translation_structs_result = find_file_in_translation_structs(
        translation_structs,
        tab_name
      )
      next if translation_structs_result.nil?

      translation_structs_result
    end.compact
  end

  def xlsx_sheets(xlsx_file)
    xlsx_file.sheets.drop(1)
  end

  def xlsx_content(path)
    Roo::Spreadsheet.open(path)
  end

  def initialize_imports_directory
    imports_directory = Rails.root.join(config['imports_directory'])
    return if File.exist?(imports_directory)

    FileUtils.mkdir_p(imports_directory)
    raise "\n\n\n"\
    "Cannot start import, directory 'vendor/imports/' didn't existed in the "\
    'application directory structure (so it was empty). '\
    "We've created it for you now.\n\n\n"
  end

  def find_file_in_translation_structs(translation_structs, file)
    translation_structs.each do |struct|
      return struct if file == excel_compiler.tab_name(struct)
    end
  end

  def translation_list_builder
    @translation_list_builder ||= TranslationListBuilder.new(
      only_missing: only_missing, config: config, base_path: base_path
    )
  end

  def excel_compiler
    @excel_compiler ||= ExcelTranslationCompiler.new(
      only_missing: only_missing, config: config, write_manual: true,
      base_path: base_path
    )
  end

end
