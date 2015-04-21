require 'landable'

#this needs to read from config.
ampq_configuration = {:host => "foo",
                      :vhost => "foo",
                      :user => "foo",
                      :password => "foolol",
                      :threaded => true,
                      :exchange => "foo"}.freeze

MESSAGING_SERVICE = Landable::AmpqMessagingService.new(ampq_configuration)