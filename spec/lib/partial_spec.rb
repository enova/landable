require 'spec_helper'

module Landable
  describe Partial do
    # Defined in spec/dummy/app/views/partials/...
    let(:partials) { ['partials/test', 'partials/random'] }

    describe '#to_template' do
      context 'with configured partials' do
        before :each do
          Landable.configuration.stub(:partials_to_templates).and_return(partials)
          Partial.all.map(&:to_template)

          @random = Landable::Template.where(file: 'partials/random').first
          @test   = Landable::Template.where(file: 'partials/test').first
        end

        it 'creates templates' do
          Landable::Template.count.should == 2
        end

        context 'the templates' do
          it 'populates a name' do
            @random.name.should == 'Random'
            @test.name.should   == 'Test'
          end

          it 'populates a description' do
            @random.description.should == 'Defined in Source Code at partials/random'
            @test.description.should   == 'Defined in Source Code at partials/test'
          end

          it 'are not editable' do
            @random.editable.should == false
            @test.editable.should   == false
          end

          it 'are not layouts' do
            @random.is_layout.should == false
            @test.is_layout.should   == false
          end

          it 'popules a thumbnail_url' do
            @random.thumbnail_url.should == 'http://placehold.it/300x200'
            @test.thumbnail_url.should   == 'http://placehold.it/300x200'
          end

          it 'populates a body' do
            # Defined in spec/dummy/app/views/partials/...
            @random.body.should == ''
            @test.body.should   == ''
          end

          it 'references the flle path' do
            @random.file.should == 'partials/random'
            @test.file.should   == 'partials/test'
          end
        end
      end

      context 'with no configured partials' do
        it 'does nothing' do
          Landable.configuration.stub(:partials_to_templates).and_return([])
          Partial.all.map(&:to_template)

          Landable::Template.count.should == 0
        end
      end
    end

    describe '::files' do
      it 'returns an array of files' do
        Landable.configuration.stub(:partials_to_templates).and_return(partials)

        Partial.files.count.should == 2
        Partial.files.should include('partials/test', 'partials/random')
      end

      context 'no files' do
        it 'returns an empty array' do
          Landable.configuration.stub(:partials_to_templates).and_return([])

          Partial.files.should == []
        end
      end
    end
  end
end
