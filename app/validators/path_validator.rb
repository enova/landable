class PathValidator < ActiveModel::Validator
  def validate(record)
    if exact_match?(record.path) || regex_match?(record.path)
      record.errors[:path] << "is Reserved!"
    end
  end

  def exact_match?(path)
    Landable.configuration.reserved_paths.include? path
  end

  def regex_match?(path)
    regexs = Landable.configuration.reserved_paths.reject { |reserved_path| reserved_path.starts_with?('/') }

    regexs.each do |regex|
      return true if Regexp.new(regex).match(path)
    end

    false
  end
end
