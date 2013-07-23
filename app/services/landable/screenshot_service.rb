require 'rest-client'

module Landable

  class ScreenshotService

    include Landable::Engine.routes.url_helpers

    DEFAULT_BROWSERS = [
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
      },
      {
        os: 'Windows',
        os_version: '7',
        browser: 'ie',
        browser_version: '9.0',
      },
      {
        os: 'OS X',
        os_version: 'Lion',
        browser: 'safari',
        browser_version: '6.0',
      },
      {
        os: 'OS X',
        os_version: 'Lion',
        browser: 'opera',
        browser_version: '12.0',
      },
      {
        os: 'android',
        os_version: '4.1',
        browser: 'Android Browser',
        device: 'Samsung Galaxy S III',
      },
      {
        os: 'android',
        os_version: '2.3',
        browser: 'Android Browser',
        device: 'Samsung Galaxy S II',
      },
      {
        os: 'ios',
        os_version: '6.0',
        browser: 'Mobile Safari',
        device: 'iPhone 4S (6.0)',
      },
      {
        os: 'ios',
        os_version: '5.1',
        browser: 'Mobile Safari',
        device: 'iPad 3rd',
      },
    ]

    def self.call screenshotable
      service = new screenshotable
      service.create_default_screenshots
      service.submit_screenshots

      service.screenshots
    end

    def self.handle_job_callback data
      data['screenshots'].each do |screenshot_data|
        screenshot = Landable::Screenshot.find_by_browserstack_id screenshot_data['id']
        next if not screenshot

        screenshot.state      = screenshot_data['state']
        screenshot.image_url  = screenshot_data['image_url']
        screenshot.thumb_url  = screenshot_data['thumb_url']
        screenshot.save!
      end
    end

    def self.available_browsers
      result = RestClient.get 'http://www.browserstack.com/screenshots/browsers.json'
      JSON.parse result
    end


    attr_accessor :screenshotable
    delegate :screenshots, to: :screenshotable

    def initialize(screenshotable)
      @screenshotable = screenshotable
    end

    def create_default_screenshots
      DEFAULT_BROWSERS.map do |browser_attributes|
        screenshots.create! browser_attributes
      end
    end

    def submit_screenshots target_screenshots = nil
      target_screenshots ||= screenshots

      payload = {
        url: screenshotable.preview_url,
        callback_url: callback_screenshots_url,
        browsers: target_screenshots.collect(&:browser_attributes),
      }.to_json

      response = RestClient.post(
        'http://www.browserstack.com/screenshots',
        payload,
        accept: :json,
        content_type: :json,
        authorization: 'Basic ' + Base64.encode64('enovamobile@gmail.com:trogdor13'),
        # user: 'enovamobile@gmail.com',
        # password: 'trogdor13',
      )

      job_data = JSON.parse(response)

      job_data['screenshots'].each do |screenshot_data|
        # grab the matching screenshot
        screenshot = target_screenshots.select { |s|
          # this is kinda crap, but it matches up by not-nil browser
          # attributes. note that browserstack doesn't return keyval pairs for
          # values that are empty.
          s.browser_attributes.reject { |k, v| v.nil? } == screenshot_data.slice(*s.browser_attributes.keys).reject { |k, v| v.nil? }
        }.first

        # apply updates
        screenshot.update_attributes!(
          'state' => screenshot_data['state'],
          'browserstack_id' => screenshot_data['id'],
          'browserstack_job_id' => job_data['job_id'],
        )
      end

      target_screenshots
    end

  end
end
