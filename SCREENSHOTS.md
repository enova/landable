# Screenshots

1.`gem install forward`
2. Enter account info
3. `forward p2p.dev` #this will spit out a host name
4. Update these files with the host name from #3:
  `config/initializers/carrierwave.rb` #config.asset_host
  `config/initializers/landable.rb`    #Landable::Engine.routes.default_url_options
5. Restart pow