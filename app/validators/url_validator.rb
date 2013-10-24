class UrlValidator < ActiveModel::EachValidator

  def validate_each(record, attribute, value)
    valid = begin
      value =~ /^[a-z]+\:\/\// or value =~ /^\//
    end

    unless valid
      record.errors[attribute] << ("Invalid URL! Make sure it starts with http:// or /")
    end
  end

end