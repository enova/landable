require 'spec_helper'

module Landable
  describe Screenshot do

    it { should belong_to :browser }

    describe '#screenshotable_type=' do
      context 'something like foobar or foo_bar' do
        it 'should assign the titleized version with a Landable namespace' do
          screenshot = build :page_screenshot
          screenshot.screenshotable_type = 'foobar'
          screenshot.screenshotable_type.should == 'Landable::Foobar'
        end
      end

      context 'something else' do
        it 'should assign it verbatim' do
          screenshot = build :page_screenshot
          screenshot.screenshotable_type = 'Sixteen'
          screenshot.screenshotable_type.should == 'Sixteen'
        end
      end
    end

    describe '#url' do
      it 'should return #preview_url of its screenshotable' do
        screenshot = create :page_screenshot
        screenshot.screenshotable.should_receive(:preview_url) { 'some url' }
        screenshot.url.should == 'some url'
      end
    end

    describe '#browserstack_attributes' do
      it 'should delegate to :browser' do
        browserstack_attributes = double()
        screenshot = build(:page_screenshot)

        screenshot.browser.should_receive(:browserstack_attributes) { browserstack_attributes }

        screenshot.browserstack_attributes.should == browserstack_attributes
      end
    end

    describe 'before create' do
      context 'no state' do
        context 'no browserstack_id' do
          it 'should set state ?= "unsent"' do
            screenshot = create :page_screenshot, state: nil, browserstack_id: nil
            screenshot.state.should == 'unsent'
          end
        end

        context 'with browserstack_id' do
          it 'should do nothing to state' do
            screenshot = create :page_screenshot, state: nil, browserstack_id: 5
            screenshot.state.should be_nil
          end
        end
      end

      context 'with state' do
        it 'should keep the state' do
          screenshot = create :page_screenshot, state: 'foobar', browserstack_id: nil
          screenshot.state.should == 'foobar'
        end
      end
    end

  end
end
