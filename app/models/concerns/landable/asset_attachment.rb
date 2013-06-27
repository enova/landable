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

    def name
      local_name || global_name
    end

    def local_name
      self.alias
    end

    def global_name
      asset.name
    end
  end
end
