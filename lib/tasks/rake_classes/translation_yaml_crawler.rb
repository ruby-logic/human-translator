# This class performs sophisticated operations on a YAML file.
class TranslationYamlCrawler

  def initialize(file:, only_missing:, config:)
    @file = file
    @only_missing = only_missing
    @marker = config['missing_translation_marker']
  end

  def translation_structs
    process_file

    (0...@path_columns.size.to_i).map do |key|
      path = @path_columns.uniq[key]
      next if @translate_columns[path].nil?
      next unless current_value_includes_marker?(path, marker)

      new_translation_struct(path: path, value: @translate_columns[path])
    end.compact
  end

  private

  attr_accessor :file, :only_missing, :marker

  def new_translation_struct(path:, value:)
    # This method is the same as in TranslationListBuilder.
    OpenStruct.new(path: path, value: value)
  end

  def process_file
    @path_columns = []
    @translate_columns = {}
    @hash_path = []
    @query = 0

    @structs_to_sheet = []

    Psych.load(File.open(file)).each do |key, value|
      @hash_path << key
      single_nesting(@hash_path, value)
    end
  end

  def nested_hashes(file_hash)
    single_nesting(@hash_path, file_hash)
    remove_last_key(@hash_path, @hash_path.size - @query)
  end

  def single_nesting(keys_path, file_hash)
    @query += 1
    file_hash.each do |key, value|
      data_to_sheet(keys_path, value) if value.class != String
      keys_path << key

      validate_string(value, keys_path)
    end
    @query -= 1
  end

  def data_to_sheet(keys_path, value)
    @path_columns << keys_path.join(':')
    return unless value.is_a?(String)

    @translate_columns = @translate_columns.merge(keys_path.join(':') => value)
  end

  def validate_string(value, keys_path)
    if value.class != String
      nested_hashes(value)
    else
      data_to_sheet(keys_path, value)
      remove_last_key(keys_path, 1)
    end
  end

  def remove_last_key(object, amount)
    object.pop(amount.to_i)
  end

  def current_value_includes_marker?(path, marker)
    only_missing ? @translate_columns[path].include?(marker) : true
  end

end
