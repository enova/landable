require 'tempfile'
require 'restclient'

module Landable
  class ScreenshotService

    class << self
      def generate url, options = {}
        if not Landable.configuration.publicist_url
          Rails.logger.warn "Couldn't generate screenshot for #{url}; no Landable.configuration.publicist_url configured"
        else
          screenshots_uri = URI(Landable.configuration.publicist_url)
          screenshots_uri.path = '/api/services/screenshots'

          response = RestClient.post screenshots_uri.to_s, screenshot: options.merge(url: url)

          if response.code == 200
            file = Tempfile.new ['screenshot', (response.content_type.split(';').first.split('/').last rescue 'png')]
            file.write response.to_str
            file.rewind

            file
          end
        end
      end
    end

  end
end
