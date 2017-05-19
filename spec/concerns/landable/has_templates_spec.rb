require 'spec_helper'

module Landable
  describe HasTemplates do
    before(:each) do
      create_list :template, 2
      create :template, slug: 'I have a space'
    end

    let(:templates) { Landable::Template.last(3) }
    let(:subject) do
      build :page, body: "
          <div>{% template #{templates[0].slug} %}</div>
          <div>{% template #{templates[1].slug} %}</div>
          <div>{% template #{templates[2].slug} %}</div>
        "
    end

    describe '#templates' do
      it 'should return templates' do
        slugs = [templates[0].slug, templates[1].slug, templates[2].slug]
        expect(subject.templates).to eq Landable::Template.where(slug: slugs)
      end
    end

    describe '#template_names' do
      it 'should pull template slugs out of the body' do
        expect(subject.template_names.sort).to eq templates.map(&:slug).uniq.sort
      end
    end

    describe '#save_templates!' do
      it 'should save the templates' do
        assets_double = double
        expect(subject).to receive(:templates) { assets_double }
        expect(subject).to receive(:templates=).with(assets_double)
        subject.save_templates!
      end

      it 'should be called during save' do
        expect(subject).to receive :save_templates!
        subject.save!
      end
    end

    describe 'body=' do
      it 'should reset the template_slug cache, then set the body' do
        subject.instance_eval { @template_slug = 'foo' }
        subject.body = 'bar'
        expect(subject.body).to eq 'bar'
        expect(subject.instance_eval { @template_slug }).to be_nil
        expect(subject.templates).to eq []
      end
    end

    describe '#templates_join_table_name' do
      it 'should generate the correct join_table, and then apologize for doing so' do
        expect(Page.send(:templates_join_table_name)).to eq "#{Landable.configuration.database_schema_prefix}landable.page_templates"
      end
    end
  end
end
