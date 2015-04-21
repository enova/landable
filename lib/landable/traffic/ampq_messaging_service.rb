module Landable
  class AmpqMessagingService
    def initialize(ampq_configuration)
      @bunny = Bunny.new(ampq_configuration)
      @bunny.start
      at_exit { @bunny.stop }
    end
  end
end
