require 'spec_helper'

module Landable
  describe Partial do
    # Defined in spec/dummy/app/views/partials/...
    let(:partials) { ['partials/test', 'partials/foobazz'] }

    describe '#to_template' do
      context 'with configured partials' do
        before :each do
          allow(Landable.configuration).to receive(:partials_to_templates).and_return(partials)
          Partial.all.map(&:to_template)

          @foobazz = Landable::Template.where(file: 'partials/foobazz').first
          @test    = Landable::Template.where(file: 'partials/test').first
        end

        it 'creates the templates' do
          expect(Landable::Template.all).to include(@foobazz)
          expect(Landable::Template.all).to include(@test)
        end

        context 'the templates' do
          it 'populates a name by humanizing the file' do
            expect(@foobazz.name).to eq 'Partials Foobazz'
            expect(@test.name).to eq 'Partials Test'
          end

          it 'populates a description' do
            expect(@foobazz.description).to eq 'The Code for this template can be seen at partials/foobazz in the source code'
            expect(@test.description).to eq 'The Code for this template can be seen at partials/test in the source code'
          end

          it 'are not editable' do
            expect(@foobazz.editable).to eq false
            expect(@test.editable).to eq false
          end

          it 'are not layouts' do
            expect(@foobazz.is_layout).to eq false
            expect(@test.is_layout).to eq false
          end

          it 'popules a thumbnail_url' do
            expect(@foobazz.thumbnail_url).to eq 'http://placehold.it/300x200'
            expect(@test.thumbnail_url).to eq 'http://placehold.it/300x200'
          end

          it 'populates a body' do
            expect(@foobazz.body).to eq ''
            expect(@test.body).to eq ''
          end

          it 'references the flle path' do
            expect(@foobazz.file).to eq 'partials/foobazz'
            expect(@test.file).to eq 'partials/test'
          end

          it 'creates a slug by underscoring the name' do
            expect(@test.slug).to eq 'partials_test'
            expect(@foobazz.slug).to eq 'partials_foobazz'
          end

          it 'creates a published template' do
            expect(@test.revisions.present?).to eq true
            expect(@foobazz.revisions.present?).to eq true
          end
        end
      end
    end

    describe '::files' do
      it 'returns an array of files' do
        allow(Landable.configuration).to receive(:partials_to_templates).and_return(partials)

        expect(Partial.files.count).to eq 2
        expect(Partial.files).to include('partials/test', 'partials/foobazz')
      end

      context 'with no configured partials' do
        it 'has no files' do
          allow(Landable.configuration).to receive(:partials_to_templates).and_return([])

          expect(Partial.files).to eq []
        end
      end
    end
  end
end
