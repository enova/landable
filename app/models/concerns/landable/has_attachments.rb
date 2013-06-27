module Landable
  module HasAttachments
    extend ActiveSupport::Concern

    included do
      has_many :asset_attachments, class_name: "#{name}Asset"
      has_many :assets, through: :asset_attachments, class_name: 'Landable::Asset'
    end

    def attachments
      @attachments ||= Attachments.new(self)
    end

    def attachments=(other)
      attachments.set other
    end
  end
end
