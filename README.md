# Landable

Landable is an API for building your CMS. It's implemented as a [Rails Engine](http://guides.rubyonrails.org/engines.html). We like to use Landable with [Publicist](https://github.com/enova/publicist), a great UI for managing content.


## Installation

Landable requires [Postgres](https://github.com/ged/ruby-pg). Make sure you have Postgres installed and configured in your app.

Add `gem 'landable'` to your project's Gemfile and run `bundle`.

Run `bundle exec rails g landable:install`, and update the new landable initializer to taste.

Open your routes file, and ensure that the engine is mounted properly. Typically, this will be your final, catch-all route:

```ruby
My::Application.routes.draw do
  mount Landable::Engine => '/'
end
```
Install Landable's migrations:

```sh
rake landable:install:migrations
rake db:migrate
```

Checkout the wiki for steps on [configuration](https://github.com/enova/landable/wiki/Configuration).

## Visit Tracking
Landable includes the ability to track visits.

```ruby
Landable.configure do |config|
  # To enable tracking, put one of the following in your Landable initializer:
  config.traffic_enabled = true  # Enables tracking for all requests.  (:all is also accepted here.)
  config.traffic_enabled = :html # Enables tracking for only HTML requests.
end
```

## Development

Run `./script/redb` to refresh the dummy app's database.

Run the test suite with `rake landable`.

## Contributing 
Contributions are welcome - submit a pull request.

* Do include specs to back up all code changes.
* Do add your changes to the "unreleased" section of [CHANGELOG.md](CHANGELOG.md) (adding this section if it does not exist). Include the pull request number.
* Don't bump Landable's version number.

## License

Landable is released under the [MIT License](https://github.com/enova/landable/blob/master/MIT-LICENSE).
