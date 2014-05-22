module Landable
  class Template < ActiveRecord::Base
    include Landable::TableName

    validates_presence_of   :name, :slug, :description
    validates_uniqueness_of :name, case_sensitive: false
    validates_uniqueness_of :slug, case_sensitive: false


    belongs_to :published_revision,   class_name: 'Landable::TemplateRevision'
    has_many   :audits,               class_name: 'Landable::Audit', as: :auditable
    has_many   :revisions,            class_name: 'Landable::TemplateRevision'

    has_and_belongs_to_many :pages,   join_table: Page.templates_join_table_name

    before_save -> template {
      template.is_publishable = true unless template.published_revision_id_changed?
    }

    def name= val
      self[:name] = val
      self[:slug] ||= (val && val.underscore.gsub(/[^\w_]/, '_').gsub(/_{2,}/, '_'))
    end

    def partial?
      file.present?
    end

    def publish!(options)
      transaction do
        published_revision.unpublish! if published_revision
        revision = revisions.create! options
        update_attributes!(published_revision: revision, is_publishable: false)
      end
    end

    def revert_to!(revision)
      self.name          = revision.name
      self.body          = revision.body
      self.description   = revision.description
      self.slug          = revision.slug

      save!
    end

    class << self
      def create_from_partials!
        Partial.all.map(&:to_template)
      end
    end
  end
end
