# Bootstraps and enables mocking for CarrierWave and Fog
credentials = {
  provider: 'AWS',
  aws_access_key_id: 'TEST',
  aws_secret_access_key: 'TEST'
}

CarrierWave.configure do |config|
  config.root      = Landable::Engine.root.join('tmp')
  config.cache_dir = Landable::Engine.root.join('tmp/carrier_wave')

  config.fog_credentials = credentials
  config.fog_directory   = 'landable'
end

Fog.mock!
Fog::Storage.new(credentials).directories.create(key: 'landable')
