module Landable
  class PathValidator < ActiveModel::Validator
    def validate(record)
      if match?(record.path)
        record.errors[:path] << "is Reserved!"
      end
    end

    def match?(path)
      Landable.configuration.reserved_paths.each do |reserved|
        regex = Regexp.new("^#{reserved}$", 'i')
        return true if regex.match(path)
      end

      false
    end
  end
end
