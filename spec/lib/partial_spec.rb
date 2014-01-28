require 'spec_helper'

module Landable
  describe Partial do
    # Defined in spec/dummy/app/views/partials/...
    let(:partials) { ['_test.html.haml', '_random.html.haml'] }

    describe '#to_template' do
      context 'with configured partials' do
        before :each do
          Landable.configuration.stub(:partials_to_templates).and_return(partials)
          Partial.all.map(&:to_template)

          @test   = Landable::Template.where(file: "test.html.haml").first
          @random = Landable::Template.where(file: "random.html.haml").first
        end

        it 'creates templates' do
          Landable::Template.count.should == 2
        end

        context 'the templates' do
          it 'populates a name' do
            @test.name.should   == 'test'
            @random.name.should == 'random'
          end

          it 'populates a description' do
            @test.description.should   == 'Defined in test.html.haml'
            @random.description.should == 'Defined in random.html.haml'
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
            @random.body.should include('Repay between 6 and 12 months')
            @test.body.should   include('Customer Testimonials')
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

        Partial.files.should == [Dir[Rails.root.join("**/app/views/partials/_test.html.haml")].first, 
                                 Dir[Rails.root.join("**/app/views/partials/_random.html.haml")].first]        
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
