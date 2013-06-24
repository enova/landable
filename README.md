# Landable
Rails engine providing an API and such for managing mostly static content.

It will likely also contain CSS and JS assets which provide common component implementations.

## Installation
Mount the engine, typically as your final, catch-all route:

~~~~ruby
My::Application.routes.draw do
  mount Landable::Engine => '/'
end
~~~~

To enable asset management, you will also have to configure [CarrierWave][carrierwave] and,
typically, [Fog][fog]:

~~~~ruby
# config/initializers/landable.rb, perhaps
Landable.configure do |config|
  config.api_namespace = '/my/custom/namespace'
end

CarrierWave.root = Rails.root
CarrierWave.configure do |config|
  config.fog_credentials = { ... } # See CarrierWave docs
end
~~~~


## Development
Refreshing `spec/internal/db/structure.sql`:

~~~~sh
./bin/redb
~~~~

## See Also
Documentation:

1. [doc/DOMAIN.md](http://git.cashnetusa.com/trogdor/landable/blob/rails4/doc/DOMAIN.md)
1. [doc/API.md](http://git.cashnetusa.com/trogdor/landable/blob/rails4/doc/API.md)

Related projects we are also building:

1. [publicist](http://git.cashnetusa.com/trogdor/publicist): a web app for working with landable applications

[carrierwave]: https://github.com/carrierwaveuploader/carrierwave
[fog]: https://github.com/fog/fog
