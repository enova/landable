class UrlValidator < ActiveModel::EachValidator

  def validate_each(record, attribute, value)
    valid = begin
      URI.parse(value).kind_of?(URI::HTTP)
    rescue URI::InvalidURIError
      false
    end
    unless valid
      record.errors[attribute] << ("Invalid URL! Make sure it starts with http:// or https://")
    end
  end

end