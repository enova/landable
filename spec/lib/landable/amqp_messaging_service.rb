class AmqpMessagingService
  def initialize
    @bunny_queue = 'test_queue'
  end
  def publish(message)
    #this just returns the message to the caller, for testing
    message
  end
end
