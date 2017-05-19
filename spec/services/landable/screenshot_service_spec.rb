require 'spec_helper'

module Landable
  describe ScreenshotService do
    let(:publicist_url) { nil }
    let(:screenshot_url) { 'http://google.com/asdf' }
    let(:screenshot_content) { 'screenshot-content' }

    before(:each) do
      allow(Landable.configuration).to receive(:publicist_url) { publicist_url }
    end

    describe '#capture' do
      context 'with configured publicist url' do
        let(:publicist_url) { 'http://publicist.foo/' }

        it 'should return a file pointer to the downloaded screenshot' do
          expect(Net::HTTP).to receive(:post_form) do |uri, params|
            expect(uri.to_s).to eq 'http://publicist.foo/api/services/screenshots'
            expect(params).to eq('screenshot[url]' => screenshot_url)

            double('response', code: '200', content_type: 'image/png', body: screenshot_content)
          end

          screenshot = ScreenshotService.capture screenshot_url

          expect(screenshot).to be_a Tempfile
          expect(screenshot.read).to eq screenshot_content
        end
      end

      context 'without configured publicist url' do
        it 'should return nil with a warning' do
          expect(Net::HTTP).not_to receive(:post_form)

          expect(Rails.logger).to receive(:warn).with(/#{screenshot_url}/)

          expect(ScreenshotService.capture(screenshot_url)).to be_nil
        end
      end
    end
  end
end
