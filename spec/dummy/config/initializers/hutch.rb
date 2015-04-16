# This is simply a basic example of how you can configure the hutch gem within
# your application.
Hutch::Config.initialize(
  mq_host: 'example-rabbit.com',
  mq_api_host: 'example-rabbit.com',
  mq_exchange: 'hutch'
)
