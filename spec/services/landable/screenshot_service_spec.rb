require 'spec_helper'

describe Landable::ScreenshotService do

  include Landable::Engine.routes.url_helpers

  let(:screenshotable) { create :page }
  let(:service) { Landable::ScreenshotService.new screenshotable }

  describe '.call' do
    it 'should initialize, create default screenshots, and submit them' do
      service = double('service')

      Landable::ScreenshotService.should_receive(:new).with(screenshotable) { service }
      service.should_receive(:create_default_screenshots).ordered
      service.should_receive(:submit_screenshots).ordered
      service.should_receive(:screenshots).ordered { 'screenshots' }

      Landable::ScreenshotService.call(screenshotable).should == 'screenshots'
    end
  end

  describe '.handle_job_callback' do
    let(:screenshot) { create :page_screenshot, browserstack_id: '034512d12b641c02406affc7d3b0d9e1e626c35a' }

    it 'should update the referenced screenshots' do
      screenshot

      input = {"state"=>"done", "wait_time"=>5, "mac_res"=>"1024x768",
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

        Landable::ScreenshotService.handle_job_callback input

        screenshot.reload

        screenshot.state.should     == input['screenshots'][0]['state']
        screenshot.thumb_url.should == input['screenshots'][0]['thumb_url']
        screenshot.image_url.should == input['screenshots'][0]['image_url']
    end
  end

  describe '.available_browsers' do
    it 'should retrieve browser data from browserstack' do
      result = {'one' => 'two'}

      RestClient.should_receive(:get).with('http://www.browserstack.com/screenshots/browsers.json') { result.to_json }

      Landable::ScreenshotService.available_browsers.should == result
    end
  end

  describe '#create_default_screenshots' do
    let(:default_browsers) {
      [
        {
          os: 'Windows',
          os_version: '7',
          browser: 'chrome',
          browser_version: '27.0',
        },
        {
          os: 'Windows',
          os_version: '7',
          browser: 'firefox',
          browser_version: '21.0',
        }
      ]
    }

    it 'creates screenshots according to DEFAULT_BROWSERS' do
      stub_const 'Landable::ScreenshotService::DEFAULT_BROWSERS', default_browsers

      screenshots = double('screenshots')
      service.stub(:screenshots) { screenshots }

      default_browsers.should_not be_empty
      default_browsers.each { |browser| service.screenshots.should_receive :create!, browser }

      service.create_default_screenshots
    end
  end

  describe '#submit_screenshots' do
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
        },
        {
          'os' => 'ios',
          'os_version' => '6.0',
          'id' => '1f3a6054e09592e239e9ea79c247b077e68d3d71',
          'state' => 'pending',
          'device' => 'iPhone 4S (6.0)',
          'url' => 'www.google.com',
        }]
      }
    }

    let(:screenshots) {
      response['screenshots'].map do |s|
        create :page_screenshot, {browserstack_id: nil, browserstack_job_id: nil, os_version: nil, browser_version: nil, browser: nil}.merge(s.except('url', 'id'))
      end
    }

    it 'should submit to browsershots, and update screenshots with results' do
      service.stub(:screenshots) { screenshots }

      RestClient.should_receive(:post).with(
        'http://www.browserstack.com/screenshots',
        {
          url: screenshotable.preview_url,
          callback_url: callback_screenshots_url,
          browsers: screenshots.map(&:browser_attributes),
        }.to_json,
        accept: :json,
        content_type: :json,
        authorization: 'Basic ' + Base64.encode64('enovamobile@gmail.com:trogdor13'),
      ) { response.to_json }

      service.submit_screenshots

      screenshots.size.should == 2
      screenshots[0].browserstack_id.should == response['screenshots'][0]['id']
      screenshots[1].browserstack_id.should == response['screenshots'][1]['id']
    end
  end

end