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
      new(screenshotable).submit_job
    end


    attr_accessor :screenshotable

    def initialize(screenshotable)
      @screenshotable = screenshotable
    end

    def submit_job
      payload = {
        url: screenshotable.preview_url,
        callback_url: callback_screenshots_url,
        browsers: DEFAULT_BROWSERS,
      }.to_json

      response = RestClient.post(
        'http://www.browserstack.com/screenshots',
        payload,
        accept: :json,
        content_type: :json,
        authorization: 'Basic ' + Base64.encode64('enovamobile@gmail.com:trogdor13'),
        # user: 'enovamobile@gmail.com',
        # password: 'trogdor13',
        # user_agent: 'Mozilla/5.0 (Windows NT 6.2; WOW64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/29.0.1547.2 Safari/537.36',
      )

      job_data = JSON.parse(response)

      job_data['screenshots'].map do |screenshot_data|
        screenshot_attrs = screenshot_data.except 'url'
        screenshot_attrs['browserstack_id'] = screenshot_attrs.delete 'id'
        screenshot_attrs['browserstack_job_id'] = job_data['job_id']

        screenshotable.screenshots.create! screenshot_attrs
      end
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

  end
end
