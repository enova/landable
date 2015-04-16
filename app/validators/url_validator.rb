class UrlValidator < ActiveModel::EachValidator
  def validate_each(record, attribute, value)
    valid = begin
      value =~ %r{^[a-z]+\:\/\/} || value =~ %r{^\/}
    end
    return if valid

    record.errors[attribute] << ('Invalid URL! Make sure it starts with http:// or /')
  end
end
