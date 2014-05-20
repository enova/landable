require 'spec_helper'

module Landable
  describe TemplateRevision do
    let(:author) { create(:author) }

    let(:template) do
      create(:template, name: 'Title', body: 'body', 
                        slug: 'title', description: 'awesome template')
    end

    let(:revision) do
      TemplateRevision.new template_id: template.id, author_id: author.id
    end

    describe '#template_id=' do
      it 'should set template revision attributes matching the template' do
        attrs = revision.attributes.except('editable', 'is_publishable', 'created_at', 'updated_at', 'published_revision_id', 'file', 'thumbnail_url', 'is_layout', 'is_minor', 'ordinal', 'notes', 'is_published', 'audit_flags')
        attrs.should include(template.attributes.except(*TemplateRevision.ignored_template_attributes))
      end
    end

    describe '#is_published' do
      it 'should set is_published to true and false as requested' do
        revision = TemplateRevision.new
        revision.template_id = template.id
        revision.author_id = author.id
        revision.unpublish!
        revision.is_published.should == false
        revision.publish!
        revision.is_published.should == true
      end
    end
  end
end
