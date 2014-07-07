require 'spec_helper'

module Landable
  describe Partial do
    # Defined in spec/dummy/app/views/partials/...
    let(:partials) { ['partials/test', 'partials/foobazz'] }

    describe '#to_template' do
      context 'with configured partials' do
        before :each do
          Landable.configuration.stub(:partials_to_templates).and_return(partials)
          Partial.all.map(&:to_template)

          @foobazz = Landable::Template.where(file: 'partials/foobazz').first
          @test    = Landable::Template.where(file: 'partials/test').first
        end

        it 'creates the templates' do
          Landable::Template.all.should include(@foobazz)
          Landable::Template.all.should include(@test)
        end

        context 'the templates' do
          it 'populates a name by humanizing the file' do
            @foobazz.name.should == 'Partials Foobazz'
            @test.name.should    == 'Partials Test'
          end

          it 'populates a description' do
            @foobazz.description.should == 'The Code for this template can be seen at partials/foobazz in the source code'
            @test.description.should    == 'The Code for this template can be seen at partials/test in the source code'
          end

          it 'are not editable' do
            @foobazz.editable.should == false
            @test.editable.should    == false
          end

          it 'are not layouts' do
            @foobazz.is_layout.should == false
            @test.is_layout.should    == false
          end

          it 'popules a thumbnail_url' do
            @foobazz.thumbnail_url.should == 'http://placehold.it/300x200'
            @test.thumbnail_url.should    == 'http://placehold.it/300x200'
          end

          it 'populates a body' do
            @foobazz.body.should == ''
            @test.body.should    == ''
          end

          it 'references the flle path' do
            @foobazz.file.should == 'partials/foobazz'
            @test.file.should    == 'partials/test'
          end

          it 'creates a slug by underscoring the name' do
            @test.slug.should    == 'partials_test'
            @foobazz.slug.should == 'partials_foobazz'
          end

          it 'creates a published template' do
            @test.revisions.present?.should be_true
            @foobazz.revisions.present?.should be_true
          end
        end
      end
    end

    describe '::files' do
      it 'returns an array of files' do
        Landable.configuration.stub(:partials_to_templates).and_return(partials)

        Partial.files.count.should == 2
        Partial.files.should include('partials/test', 'partials/foobazz')
      end

      context 'with no configured partials' do
        it 'has no files' do
          Landable.configuration.stub(:partials_to_templates).and_return([])

          Partial.files.should == []
        end
      end
    end
  end
end
