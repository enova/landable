class PathValidator < ActiveModel::Validator
  def validate(record)
    record.errors[:path] << 'is Reserved!' if match?(record.path)
  end

  def match?(path)
    # See if the applying path matches any reserved_paths via a Regex
    Landable.configuration.reserved_paths.any? { |reserved| Regexp.new("^#{reserved}$", 'i').match(path) }
  end
end
