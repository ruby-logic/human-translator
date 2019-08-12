# This class will help you build a list of translations suiting your needs.
class TranslationListBuilder

  def initialize(only_missing: false, config: nil, base_path: nil)
    @config = config
    @base_path = base_path
    @marker = config['missing_translation_marker']
    @only_missing = only_missing

    raise 'Marker is required - add it to config.' if @marker.nil?
  end

  def language_structs(language)
    all_files_for_language(language).map.with_index(1) do |file, index|
      next unless file_qualifies_to_list?(file, language)

      new_language_struct(language: language, index: index, file: file)
    end.compact
  end

  def language_directories
    Dir.glob(File.join(base_path, '**'))
  end

  private

  attr_accessor :config, :base_path, :marker, :only_missing

  def new_language_struct(language:, index:, file:)
    OpenStruct.new(
      language: language,
      index: index,
      file: file,
      basename: File.basename(file)
    )
  end

  def language_path(language)
    File.join(base_path, language)
  end

  def file_qualifies_to_list?(file, language)
    return false if excluded_file?(File.basename(file), language)

    only_missing ? File.readlines(file).any? { |line| line[marker] } : true
  end

  def excluded_file?(basename, language)
    config['excluded_files'].include?(
      File.basename(basename, ".#{language}.yml")
    )
  end

  def all_files_for_language(language)
    Dir.glob(File.join(language_path(language), '**', '*')).sort.map do |file|
      file if File.file?(file)
    end.compact
  end

end
