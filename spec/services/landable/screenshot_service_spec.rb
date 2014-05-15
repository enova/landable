require 'spec_helper'

module Landable
  describe ScreenshotService do
    let(:publicist_url) { nil }
    let(:screenshot_url) { 'http://google.com/asdf' }
    let(:screenshot_content) { 'screenshot-content' }

    before(:each) do
      Landable.configuration.stub(:publicist_url) { publicist_url }
    end

    describe '#generate' do
      context 'with configured publicist url' do
        let(:publicist_url) { 'http://publicist.foo/' }

        it 'should return a file pointer to the downloaded screenshot' do
          options = {foo: 'bar'}

          RestClient.should_receive(:post).with('http://publicist.foo/api/services/screenshots', screenshot: {url: screenshot_url, foo: 'bar'}) {
            double('response', code: 200, content_type: 'image/png', to_str: screenshot_content)
          }

          screenshot = ScreenshotService.generate screenshot_url, foo: 'bar'

          screenshot.should be_a Tempfile
          screenshot.read.should == screenshot_content
        end
      end

      context 'without configured publicist url' do
        it 'should return nil with a warning' do
          RestClient.should_not_receive(:post)

          Rails.logger.should_receive(:warn).with(/#{screenshot_url}/)

          ScreenshotService.generate(screenshot_url).should be_nil
        end
      end
    end
  end
end
