require 'spec_helper'

module Landable
  describe HasTemplates do

    before(:each) { create_list :template, 3 }

    let(:templates) { Landable::Template.last(3) }
    let(:subject) {
      build :page, {
        body: "
          <div>{% template #{templates[0].slug} %}</div>
          <div>{% template #{templates[1].slug} %}</div>
          <div>{% template #{templates[2].slug} %}</div>
        "
      }
    }

    describe '#templates' do
      it 'should return templates' do
        slugs = [templates[0].slug, templates[1].slug, templates[2].slug]
        subject.templates.should == Landable::Template.where(slug: slugs)
      end
    end

    describe '#template_names' do
      it 'should pull template slugs out of the body' do
        subject.template_names.sort.should == templates.map(&:slug).uniq.sort
      end
    end

    describe '#save_templates!' do
      it 'should save the templates' do
        assets_double = double()
        subject.should_receive(:templates) { assets_double }
        subject.should_receive(:templates=).with(assets_double)
        subject.save_templates!
      end

      it 'should be called during save' do
        subject.should_receive :save_templates!
        subject.save!
      end
    end

    describe 'body=' do
      it 'should reset the template_slug cache, then set the body' do
        subject.instance_eval { @template_slug = 'foo' }
        subject.body = 'bar'
        subject.body.should == 'bar'
        subject.instance_eval { @template_slug }.should be_nil
        subject.templates.should == []
      end
    end

    describe '#templates_join_table_name' do
      it 'should generate the correct join_table, and then apologize for doing so' do
        Page.send(:templates_join_table_name).should == "#{Landable.configuration.database_schema_prefix}landable.page_templates"
      end
    end
  end
end
