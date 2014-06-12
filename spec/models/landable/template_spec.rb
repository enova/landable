require 'spec_helper'

module Landable
  describe Template do
    describe 'validators' do
      # some valid seed data
      before(:each) { create :template }

      it { should validate_presence_of :name }
      it { should validate_presence_of :description }
      it { should validate_presence_of :slug }
      it { should validate_uniqueness_of :slug }
    end

    describe '#name=' do
      context 'without a slug' do
        it 'should assign a slug' do
          template = build(:template, slug: nil)
          template.name = 'Six Seven'
          template.name.should == 'Six Seven'
          template.slug.should == 'six_seven'
        end
      end

      context 'with a slug' do
        it 'should leave the slug alone' do
          template = build(:template, slug: 'six')
          template.name = 'seven'
          template.name.should == 'seven'
          template.slug.should == 'six'
        end
      end
    end

    describe '#partial?' do
      it 'returns true when template references a file' do
        template = create :template, :partial
        template.partial?.should be_true
      end

      it 'returns false when template has no file' do
        template = create :template
        template.partial?.should be_false
      end
    end

    describe '#publish' do
      let(:template) { FactoryGirl.create :template }
      let(:author) {   FactoryGirl.create :author }

      it 'should create a template_revision' do
        expect {template.publish!(author: author)}.to change{template.revisions.count}.from(0).to(1)
      end

      it 'should have the provided author' do
        template.publish! author: author
        revision = template.revisions.last

        revision.author.should == author
      end

      it 'should update the published_revision_id' do
        template.publish! author: author
        revision = template.revisions.last

        template.published_revision.should == revision
      end

      it 'should unset previous revision.is_published' do
        template.publish! author: author
        revision1 = template.published_revision
        template.publish! author: author
        revision1.is_published.should be_false
      end

      it 'should call republish_associated_pages' do
        page = create :page
        template.pages = [page]
        template.save!

        template.should_receive(:republish_associated_pages)
        template.publish! author: author
      end
    end

    describe '#revert_to' do
      let(:template) { FactoryGirl.create :template }
      let(:author) { FactoryGirl.create :author }

      it 'should NOT update published_revision for the page' do
        template.name = 'Bar'
        template.publish! author: author
        revision = template.published_revision

        template.name = 'Foo'
        template.publish! author: author

        template.revert_to! revision

        template.published_revision.id.should_not == revision.id
      end

      it 'should copy revision attributes into the page model' do
        template.name = 'Bar'
        template.publish! author: author

        revision = template.published_revision

        template.name = 'Foo'
        template.save!
        template.publish! author: author

        # ensure assignment for all copied attributes
        keys = %w(name body description slug)
        keys.each do |key|
          template.should_receive("#{key}=").with(revision.send(key))
        end

        template.revert_to! revision
      end
    end
  end
end
