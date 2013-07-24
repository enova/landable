# Screenshots

Haven't worked out a good way to automatically set up a localtunnel (or similar) when in development. So, because testing screenshots requires a publicly accessible dev server, perform the following if/when you want to use this feature:

1. `gem install localtunnel`
2. `localtunnel 3000` (you will be prompted to run localtunnel again the first time, providing your ssh public key)
3. Make a note of the tunnel hostname that is printed (e.g. abcd.localtunnel.com)
4. Update the `:host` value in your application's `Landable::Engine.routes.default_url_options` - probably found in `config/initializers/landable.rb`
5. `rails s` to start rails on port 3000, then `powify restart`

This approach does result in having two instances of your application running simultaneously. I'm going to get a [Forward](https://forwardhq.com/) account rolling here soon to allow us to forward `p2p.dev`, etc, instead of having to start something new on a different port.