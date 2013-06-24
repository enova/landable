module Landable
  module AssetAttachment
    extend ActiveSupport::Concern

    included do
      belongs_to :asset
    end

    def alias=(value)
      value = value.blank? ? nil : value
      write_attribute(:alias, value)
    end
  end
end
