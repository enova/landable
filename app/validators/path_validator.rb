class PathValidator < ActiveModel::Validator
  def validate(record)
    if match?(record.path)
      record.errors[:path] << "is Reserved!"
    end
  end

  def match?(path)
    # See if the applying path matches any reserved_paths via a Regex
    Landable.configuration.reserved_paths.any? { |reserved| Regexp.new("^#{reserved}$", 'i').match(path) }
  end
end
