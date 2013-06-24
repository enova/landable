# Bootstraps and enables mocking for CarrierWave and Fog
require 'carrierwave'
CarrierWave.root = Landable::Engine.root

credentials = {
  provider: 'AWS',
  aws_access_key_id: 'TEST',
  aws_secret_access_key: 'TEST'
}

CarrierWave.configure do |config|
  config.fog_credentials = credentials
  config.fog_directory   = 'landable'
end

Fog.mock!
Fog::Storage.new(credentials).directories.create(key: 'landable')
