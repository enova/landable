require 'spec_helper'

module Landable
  describe Template do
    describe 'validators' do
      # some valid seed data
      before(:each) { create :template }

      it { is_expected.to validate_presence_of :name }
      it { is_expected.to validate_presence_of :description }
      it { is_expected.to validate_presence_of :slug }
    end

    describe '#name=' do
      context 'without a slug' do
        it 'should assign a slug' do
          template = build(:template, slug: nil)
          template.name = 'Six Seven'
          expect(template.name).to eq 'Six Seven'
          expect(template.slug).to eq 'six_seven'
        end
      end

      context 'with a slug' do
        it 'should leave the slug alone' do
          template = build(:template, slug: 'six')
          template.name = 'seven'
          expect(template.name).to eq 'seven'
          expect(template.slug).to eq 'six'
        end
      end
    end

    describe '#partial?' do
      it 'returns true when template references a file' do
        template = create :template, :partial
        expect(template.partial?).to eq true
      end

      it 'returns false when template has no file' do
        template = create :template
        expect(template.partial?).to eq false
      end
    end

    describe '#publish' do
      let(:template) { FactoryGirl.create :template }
      let(:author) {   FactoryGirl.create :author }

      it 'should create a template_revision' do
        expect { template.publish!(author: author) }.to change { template.revisions.count }.from(0).to(1)
      end

      it 'should have the provided author' do
        template.publish! author: author
        revision = template.revisions.last

        expect(revision.author).to eq author
      end

      it 'should update the published_revision_id' do
        template.publish! author: author
        revision = template.revisions.last

        expect(template.published_revision).to eq revision
      end

      it 'should unset previous revision.is_published' do
        template.publish! author: author
        revision1 = template.published_revision
        template.publish! author: author
        expect(revision1.is_published).to eq false
      end

      it 'should call republish_associated_pages' do
        page = create :page
        template.pages = [page]
        template.save!

        expect(template).to receive(:republish_associated_pages)
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

        expect(template.published_revision.id).not_to eq revision.id
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
          expect(template).to receive("#{key}=").with(revision.send(key))
        end

        template.revert_to! revision
      end
    end

    describe '#slug_has_no_spaces' do
      it 'should not allow a slug with out underscores' do
        t = build :template, slug: 'I have no space'
        t.name = 'No Space'
        t.save!

        expect(t.slug).not_to eq 'I have no space'
        expect(t.slug).to eq 'i_have_no_space'
      end

      it 'should allow the name to set the slug' do
        t = build :template, slug: nil
        t.name = 'I have no space'
        t.save!

        expect(t.slug).to eq 'i_have_no_space'
      end
    end
  end
end
