# Landable

Rails engine providing an API and such for managing mostly static content.


## Installation

Add `gem 'landable'` to your project's Gemfile.

Run `bundle exec rails g landable:install`, and update the new landable initializer to taste.

Open your routes file, and ensure that the engine is mounted properly. Typically, this will be your final, catch-all route:

```ruby
My::Application.routes.draw do
  mount Landable::Engine => '/'
end
```

Asset storage defaults to the local filesystem. To modify this, configure [CarrierWave][carrierwave] and [Fog][fog]:

```ruby
# config/initializers/carrier_wave.rb, perhaps
CarrierWave.configure do |config|
  config.root      = Rails.root.join('public/uploads')
  config.cache_dir = Rails.root.join('tmp/carrierwave')

  # For example, using Fog for AWS:
  config.store = :fog
  config.fog_credentials = {
    provider: 'AWS',
    # etc; see the CarrierWave and Fog docs.
  }

  # Or, in development or test, maybe just store locally:
  config.store = :file
end
```

Finally, install Landable's migrations:

```sh
rake landable:install:migrations
rake db:migrate
```

### Categories
Landable comes with default categories that you can see [here](https://git.cashnetusa.com/trogdor/landable/blob/master/lib/landable/configuration.rb#L34). You can overwrite these categories in your initializer.

```ruby
Landable.configure do |config|
  config.categories.merge!({ 'CatName' => 'Description', 
                             'CatName2' => 'Description2' })
end
```

### Sitemap
Landable comes with an automatic sitemap generator that you can configure in your initializer. See your sitemap at ```/sitemap.xml```

```ruby
Landable.configure do |config|
  # Keeps pages with testing category out of sitemap (defaults to [])
  config.sitemap_exclude_categories = %w(Testing) 
  
  # Configures protocol to be used in sitemap (defaults to 'http')
  config.sitemap_protocol = "https" 
  
  # Configures host name to be used in sitemap (defaults to 'request.host')
  config.sitemap_host = "www.example.com" 
  
  # Landable sitemap generator only includes pages in Landable.  To include other pages, add them as an array like so in your initializer. 
  config.sitemap_additional_paths = %w(/ /terms-of-use.html /privacy-policy.html) 
end
```

### Reserving Page Paths
Landable allows you to reserve paths in your initalizer, preventing users from creating pages with these paths.

Reserved paths are case insensitive, and support regex operators.

```ruby
Landable.configure do |config|
  # Reserves /reserved_path, and paths like /reject/me, /REJECT/me, /reject/this/please,
  # /admin, /ADMiN/, and /admin/users
  config.reserved_paths = %w(/reserved_path /reject/.* /admin.*)
end
```

### Partial To Publicist Template Support
Landable allows you to create [Publicist](http://git.cashnetusa.com/trogdor/publicist) templates from application partials.

For example, let's say you wanted to create templates from your header (defined in app/views/layouts/_header.html.haml) and footer (defined in app/views/layouts/_footer.html.haml).

You can do this like so...
```ruby
Landable.configure do |config|
  config.partials_to_templates = %w(layouts/header layouts/footer)
end
```

## Visit Tracking
Landable includes the ability to track visits.

```ruby
Landable.configure do |config|
  # To enable tracking, put one of the following in your Landable initializer:
  config.traffic_enabled = true  # Enables tracking for all requests.  (:all is also accepted here.)
  config.traffic_enabled = :html # Enables tracking for only HTML requests.
end
```

## Database Schema Naming
Landable will default to putting its tables in landable, landable_traffic database schemas.

You can specify a prefix to use, which would allow for unique database schema names across applications.

```ruby
Landable.configure do |config|
  # Setup a custom database schema prefix (default: nil)
  config.database_schema_prefix = 'prefix'                                     # Would use schemas prefix_landable, prefix_landable_tracking
  config.database_schema_prefix = Rails.application.class.parent_name.downcase # Would use the downcase version of your app's name
end
```

## Development

Run `./bin/redb` to refresh the dummy app's database.

Run the test suite with `rake landable`.

Contributions are welcome - submit a pull request.

* Do include specs to back up all code changes.
* Do add your changes to the "unreleased" section of [CHANGELOG.md](CHANGELOG.md) (adding this section if it does not exist). Include the pull request number.
* Don't bump Landable's version number.


## Releases

The Landable gem may be built and released by a maintainer at any time. (If you are not a maintainer, skip the rest of this section. Extra top secret.)

1. Ensure all required pull requests have been merged.
4. Ensure `rake landable` succeeds.
2. Update `lib/landable/version.rb` according to [semantic versioning](http://semver.org/) rules.
3. Rename the unreleased section of [CHANGELOG.md](CHANGELOG.md) to the release version number. Include a Github compare link against the previous version.
4. `commit -a -m "Release vX.Y.Z"`, and push to master.
5. `rake release`

If this is your first time running a release, configure geminabox first:

```sh
gem inabox -c # when prompted, enter http://gems.enova.com as the host
```

### Versioning

Landable version numbers are based on [semver](http://semver.org/): *major*.*minor*.*patch*(.*pre*).

#### Major

Reserved for backwards-incompatible API changes. Or my birthday. Resets minor and patch counters to zero.

A major version bump must be preceded by at least one prerelease for that version (see "Prerelease", below).

#### Minor

For new public features (e.g. new API paths, but not new internal ruby methods). Resets patch counter to zero.

A minor version bump must be preceded by at least one prerelease for that version (see "Prerelease", below).

#### Patch

Sometimes there are bugs. Or refactorings. Or whitespace changes. Fixes that do not require a major or minor version bump are considered patches.

#### Prerelease

Major and minor releases are preceded by prereleases, to allow for bug discovery before locking in the release. Prereleases should be tested in development and staging deployments to determine their viability for production.

Once a prerelease is deemed production-ready, the official release for that code may be performed.

For example: Landable v2.0.0 would be preceded by Landable v2.0.0.rc1. If a bug is found, it is patched in v2.0.0.rc2. If v2.0.0.rc2 passes muster in other projects, v2.0.0 may be officially released.


## See Also

Related projects we are also building:

1. [publicist](http://git.cashnetusa.com/trogdor/publicist): a web app for working with landable applications

[carrierwave]: https://github.com/carrierwaveuploader/carrierwave
[fog]: https://github.com/fog/fog
