require File.expand_path('translation_yaml_crawler', __dir__)

# This class getting data from translations YML files
class TranslationYamlHelper

  def initialize(language_struct, only_missing:, base_language:, base_path:,
                 config:)
    @language_struct = language_struct
    @marker = config['missing_translation_marker']
    @only_missing = only_missing
    @base_language = base_language
    @base_path = base_path
    @config = config
  end

  def translation_rows
    xlsx_structs.map do |xlsx_struct|
      [
        xlsx_struct.source_text,
        xlsx_struct.contains_marker ? '' : xlsx_struct.current_text,
        xlsx_struct.path
      ]
    end.compact
  end

  def xlsx_structs
    translation_structs.map do |translation_struct|
      new_xlsx_row_struct(
        source_text: base_language_reference(translation_struct),
        current_text: translation_struct.value,
        path: translation_struct.path
      )
    end
  end

  private

  attr_accessor :file_path, :marker, :only_missing, :language_struct,
                :base_language, :base_path, :config

  def builder
    TranslationListBuilder.new(config: config, base_path: base_path)
  end

  def crawler
    TranslationYamlCrawler.new(
      file: language_struct.file,
      only_missing: only_missing,
      config: config
    )
  end

  def new_xlsx_row_struct(source_text:, current_text:, path:)
    OpenStruct.new(
      source_text: source_text, path: path,
      current_text: vaccuum_marker(current_text),
      contains_marker: marker.nil? ? false : current_text.include?(marker)
    )
  end

  def new_translation_struct(path:, value:)
    OpenStruct.new(path: path, value: value)
  end

  def base_language_reference(translation_struct)
    source_translation_struct = find_translation_struct_by_index(
      builder.language_structs(base_language),
      language_struct.index
    )
    path = translation_struct.path.split(':').tap { |a| a[0] = base_language }
    Psych.load(File.open(source_translation_struct.file)).dig(*path)
  end

  def translation_structs
    @translation_structs ||= crawler.translation_structs
  end

  def find_translation_struct_by_index(translation_structs, index)
    translation_structs.each { |struct| return struct if struct.index == index }
  end

  def vaccuum_marker(text)
    only_missing ? text.gsub(marker, '').strip : text
  end

end
