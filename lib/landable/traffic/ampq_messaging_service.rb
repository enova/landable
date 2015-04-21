module Landable
  class AmpqMessagingService
    def initialize(ampq_configuration)
      @bunny = Bunny.new(ampq_configuration)
      @bunny.start
      @bunny_ch = @bunny.create_channel
      # @bunny_queue = @bunny_ch.queue(ampq_queue)
      at_exit { @bunny.stop }
    end

    def publish(message)
      @bunny_queue = @bunny_ch.queue(Landable.configuration.ampq_queue)
      @bunny_queue.publish(message.to_s)
    end
  end
end
