module Landable
  class TemplateRevision < ActiveRecord::Base
    include Landable::TableName

    @ignored_template_attributes = %w(editable created_at updated_at published_revision_id file thumbnail_url is_layout is_publishable audit_flags deleted_at)
    class << self
      attr_accessor :ignored_template_attributes
    end

    belongs_to :template, inverse_of: :revisions
    belongs_to :author

    def template_id=(id)
      # set the value
      self[:template_id] = id

      # copy attributes from the template
      self.name          = template.name
      self.body          = template.body
      self.description   = template.description
      self.category_id   = template.category_id
      self.slug          = template.slug
    end

    def publish!
      update_attribute :is_published, true
    end

    def unpublish!
      update_attribute :is_published, false
    end
  end
end
