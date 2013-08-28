require 'rest-client'

module Landable

  class ScreenshotService

    class ConfigurationError < ::StandardError; end

    class << self
      include Landable::Engine.routes.url_helpers

      def config
        Landable.configuration.screenshots
      end

      # makeshift queue handler. when called, it'll send the first unsent
      # screenshot. a scope may be passed in - if given, it'll be used to find
      # an unsent screenshot. if the scope contains no unsent screenshot,
      # autorun will be re-run with no scope.
      def autorun scope = nil
        screenshots = scope || Landable::Screenshot.all

        if screenshots.where(state: 'pending').empty?
          next_screenshot = screenshots.where(state: 'unsent').first

          # if we have the next screenshot, call the service with it
          if next_screenshot
            call next_screenshot

          # otherwise, if we were given a scope, autorun without it
          elsif scope
            autorun
          end
        end
      end

      def call screenshot
        if not config.browserstack_username.present? or not config.browserstack_password.present?
          raise ConfigurationError, 'Your application must configure both Landable.configuration.screenshots.browserstack_username and browserstack_password.'
        end

        begin
          response = RestClient.post(
            'http://www.browserstack.com/screenshots',
            {
              url: screenshot.screenshotable.preview_url,
              callback_url: callback_screenshots_url,
              browsers: [screenshot.browserstack_attributes],
              wait_time: 10, # give images a couple more seconds to load
            }.to_json,
            accept: :json,
            content_type: :json,
            authorization: 'Basic ' + Base64.encode64(config.browserstack_username + ':' + config.browserstack_password),
          )

          job_data = JSON.parse(response)
          screenshot_data = job_data['screenshots'][0]

          # apply updates
          screenshot.update_attributes!(
            'state' => screenshot_data['state'],
            'browserstack_id' => screenshot_data['id'],
            'browserstack_job_id' => job_data['job_id'],
          )
        rescue RestClient::Exception
          screenshot.state = 'error'
          screenshot.save!
        end

        screenshot
      end

      def handle_job_callback data
        screenshots = data['screenshots'].map do |screenshot_data|
          screenshot = Landable::Screenshot.find_by_browserstack_id screenshot_data['id']
          next if not screenshot

          screenshot.state      = screenshot_data['state']
          screenshot.image_url  = screenshot_data['image_url']
          screenshot.thumb_url  = screenshot_data['thumb_url']
          screenshot.save!

          screenshot
        end

        # run the next screenshot, if autorun is on
        autorun(screenshots.last.screenshotable.screenshots) if config.autorun
      end

      def import_browserstack_browsers!
        browsers_json = RestClient.get 'http://www.browserstack.com/screenshots/browsers.json'

        JSON.parse(browsers_json).each do |browsers_attributes|
          Landable::Browser.create! browsers_attributes.merge(screenshots_supported: true)
        end
      end

    end

  end
end
