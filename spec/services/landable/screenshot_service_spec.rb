require 'spec_helper'

describe Landable::ScreenshotService do

  include Landable::Engine.routes.url_helpers

  let(:screenshot) { create :page_screenshot }
  let(:service) { Landable::ScreenshotService }
  let(:config) { Landable.configuration.screenshots }

  before(:each) do
    config.stub(:autorun) { true }
    config.stub(:browserstack_username) { 'foo' }
    config.stub(:browserstack_password) { 'bar' }
  end

  describe '::autorun' do
    context 'with a given scope' do
      let(:scope) { double() }

      context 'no pending screenshots' do
        before(:each) { scope.stub(:where).with(state: 'pending') { [] } }

        context 'with an unsent screenshot' do
          before(:each) { scope.stub(:where).with(state: 'unsent') { [screenshot] } }

          it 'should call the service with the first unsent screenshot' do
            service.should_receive(:call).with(screenshot)
            service.autorun scope
          end
        end

        context 'with no unsent screenshots' do
          before(:each) { scope.stub(:where).with(state: 'unsent') { [] } }

          it 'should autorun again with no scope' do
            service.should_receive(:autorun).with(scope).and_call_original
            service.should_receive(:autorun).with()

            service.autorun scope
          end
        end
      end
    end

    context 'without a given scope' do
      let(:scope) { double() }
      before(:each) { Landable::Screenshot.stub(:all) { scope } }

      context 'no pending screenshots' do
        before(:each) { scope.stub(:where).with(state: 'pending') { [] } }

        context 'with an unsent screenshot' do
          before(:each) { scope.stub(:where).with(state: 'unsent') { [screenshot] } }

          it 'should call the service with the first unsent screenshot' do
            service.should_receive(:call).with(screenshot)
            service.autorun
          end
        end

        context 'with no unsent screenshots' do
          before(:each) { scope.stub(:where).with(state: 'unsent') { [] } }

          it 'should do nothing' do
            service.should_not_receive :call
            service.autorun
          end
        end
      end
    end

    context 'with some other pending screenshots' do
      let(:scope) { double() }
      before(:each) { scope.stub(:where).with(state: 'pending') { [screenshot] } }

      it 'should do nothing' do
        service.should_not_receive :call
        service.autorun
      end
    end
  end

  describe '::handle_job_callback' do
    let(:screenshot) { create :page_screenshot, browserstack_id: '034512d12b641c02406affc7d3b0d9e1e626c35a' }
    let(:input) {
      {"state"=>"done", "wait_time"=>5, "mac_res"=>"1024x768",
      "id"=>"9febc07a5b6b4dc82a5441b6c9454e2e4bf0a10c",
      "zipped_url"=>"http://www.browserstack.com/9febc07a5b6b4dc82a5441b6c9454e2e4bf0a10c/9febc07a5b6b4dc82a5441b6c9454e2e4bf0a10c.zip",
      "quality"=>"compressed", "orientation"=>"portrait",
      "screenshots"=>[{"state"=>"done", "browser"=>"Mobile Safari",
      "id"=>"034512d12b641c02406affc7d3b0d9e1e626c35a",
      "image_url"=>"http://www.browserstack.com/screenshots/9febc07a5b6b4dc82a5441b6c9454e2e4bf0a10c/ios_iPad-3rd_5.1_portrait.jpg",
      "created_at"=>"2013-07-17 22:21:27 UTC",
      "url"=>"http://isaacbowen.fwd.wf/-/p/fb01980f-55d3-491e-974f-6608eae968c1",
      "orientation"=>nil, "browser_version"=>nil,
      "thumb_url"=>"http://www.browserstack.com/screenshots/9febc07a5b6b4dc82a5441b6c9454e2e4bf0a10c/thumb_ios_iPad-3rd_5.1_portrait.jpg",
      "os"=>"ios", "device"=>"iPad 3rd", "os_version"=>"5.1"}],
      "callback_url"=>"http://isaacbowen.fwd.wf/api/landable/screenshots/callback",
      "win_res"=>"1024x768", "screenshot"=>{"state"=>"done"}}
    }

    it 'should update the referenced screenshots, and autorun' do
      service.should_receive(:autorun).with(screenshot.screenshotable.screenshots)

      service.handle_job_callback input

      screenshot.reload

      screenshot.state.should     == input['screenshots'][0]['state']
      screenshot.thumb_url.should == input['screenshots'][0]['thumb_url']
      screenshot.image_url.should == input['screenshots'][0]['image_url']
    end

    context 'autorun off' do
      before(:each) { config.stub(:autorun) { false } }

      it 'should not autorun after updating' do
        service.should_not_receive(:autorun)

        service.handle_job_callback input
      end
    end
  end

  describe '::import_browserstack_browsers!' do
    it 'should import browser data from browserstack' do
      result = attributes_for_list :browser, 10

      RestClient.should_receive(:get).with('http://www.browserstack.com/screenshots/browsers.json') { result.to_json }
      result.each do |browser_attributes|
        Landable::Browser.should_receive(:create!).with(browser_attributes.stringify_keys.merge(screenshots_supported: true))
      end

      Landable::ScreenshotService.import_browserstack_browsers!
    end
  end

  describe '::call' do
    let(:response) {
      {
        'job_id' => '13b93a14db22872fcb5fd1c86b730a51197db319',
        'callback_url' => 'http://staging.example.com',
        'win_res' => '1024x768',
        'mac_res' => '1920x1080',
        'quality' => 'compressed',
        'wait_time' => 5,
        'orientation' => 'portrait',
        'screenshots' => [{
          'os' => 'Windows',
          'os_version' => 'XP',
          'browser' => 'ie',
          'id' => 'be9989892cbba9b9edc2c95f403050aa4996ac6a',
          'state' => 'pending',
          'browser_version' => '7.0',
          'url' => 'www.google.com'
        }]
      }
    }

    context 'missing auth config' do
      before(:each) {
        config.stub(:browserstack_username) { nil }
        config.stub(:browserstack_password) { nil }
      }

      it 'should raise a config error' do
        expect { service.call(screenshot) }.to raise_error(Landable::ScreenshotService::ConfigurationError)
      end
    end

    context 'success' do
      it 'should submit the given screenshot to browserstack' do
        RestClient.should_receive(:post).with(
          'http://www.browserstack.com/screenshots',
          {
            url: screenshot.screenshotable.preview_url,
            callback_url: callback_screenshots_url,
            browsers: [screenshot.browserstack_attributes],
            wait_time: 10,
          }.to_json,
          accept: :json,
          content_type: :json,
          authorization: 'Basic ' + Base64.encode64('foo:bar'),
        ) { response.to_json }

        service.call(screenshot).should == screenshot

        screenshot.state.should == 'pending'
        screenshot.browserstack_id.should == response['screenshots'][0]['id']
        screenshot.browserstack_job_id.should == response['job_id']
      end
    end

    context 'error' do
      it 'should give the screenshot an error state' do
        RestClient.stub(:post) { raise Class.new(RestClient::Exception) }

        service.call(screenshot)

        screenshot.state.should == 'error'
      end
    end
  end

end