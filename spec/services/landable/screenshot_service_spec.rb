require 'spec_helper'

module Landable
  describe ScreenshotService do
    let(:publicist_url) { nil }
    let(:screenshot_url) { 'http://google.com/asdf' }
    let(:screenshot_content) { 'screenshot-content' }

    before(:each) do
      Landable.configuration.stub(:publicist_url) { publicist_url }
    end

    describe '#capture' do
      context 'with configured publicist url' do
        let(:publicist_url) { 'http://publicist.foo/' }

        it 'should return a file pointer to the downloaded screenshot' do
          Net::HTTP.should_receive(:post_form) do |uri, params|
            uri.to_s.should == 'http://publicist.foo/api/services/screenshots'
            params.should == {'screenshot[url]' => screenshot_url}

            double('response', code: '200', content_type: 'image/png', body: screenshot_content)
          end

          screenshot = ScreenshotService.capture screenshot_url

          screenshot.should be_a Tempfile
          screenshot.read.should == screenshot_content
        end
      end

      context 'without configured publicist url' do
        it 'should return nil with a warning' do
          Net::HTTP.should_not_receive(:post_form)

          Rails.logger.should_receive(:warn).with(/#{screenshot_url}/)

          ScreenshotService.capture(screenshot_url).should be_nil
        end
      end
    end
  end
end
