module Landable
  class Error < StandardError

    STATUS_CODE = 500

    def initialize message = nil
      message ||= "Status code: #{status_code} (Hint: rescue this in your ApplicationController)"
      super
    end

    def status_code
      self.class::STATUS_CODE
    end

  end
end
