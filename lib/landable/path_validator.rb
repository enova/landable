module Landable
  class PathValidator < ActiveModel::Validator
    def validate(record)
      if Landable.configuration.reserved_paths.include? record.path
        record.errors[:path] << "is Reserved!"
      else
        Landable.configuration.reserved_paths.each do |reserved|
          if Regexp.new(reserved).match(record.path)
            record.errors[:path] << "is Reserved!"
          end
        end
      end
    end
  end
end
