require 'tempfile'

module Landable
  class ScreenshotService
    class Error < StandardError; end

    class << self
      def capture(url)
        if !Landable.configuration.publicist_url
          Rails.logger.warn "Couldn't generate screenshot for #{url}; no Landable.configuration.publicist_url configured"
        else
          screenshots_uri = URI(Landable.configuration.publicist_url)
          screenshots_uri.path = '/api/services/screenshots'

          response = Net::HTTP.post_form screenshots_uri, 'screenshot[url]' => url

          if response.code == '200'
            file = Tempfile.new ['screenshot-', '.png']
            file.binmode
            file.write response.body
            file.rewind

            file
          else
            fail Error, "Received #{response.code} back from #{screenshots_uri}"
          end
        end
      end
    end
  end
end
