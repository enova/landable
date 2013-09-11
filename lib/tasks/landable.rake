require 'rspec/core'
require 'rspec/core/rake_task'

namespace :landable do

  load File.expand_path('../cucumber.rake', __FILE__)
  load File.expand_path('../pgtap.rake', __FILE__) if Rails.root.to_s.split('/').last == 'dummy'

  desc 'Run specs'
  RSpec::Core::RakeTask.new(:spec)

  desc 'Landable test suite'
  task :test => ['app:db:test:prepare', 'seed:required', :spec, :cucumber, :pgtap]

  namespace :seed do
    desc 'Populate a landable database with basic categories and themes'
    task :extras => :environment do
      # themes
      Landable::Theme.where(name: 'Blank').first_or_create!(
        body: '',
        description: 'A completely blank theme; only the page body will be rendered.',
        thumbnail_url: 'http://placehold.it/300x200',
      )

      Landable::Theme.where(name: 'Minimal').first_or_create!(
        body: File.read(File.expand_path('../minimal_theme.liquid', __FILE__)),
        description: 'A minimal HTML5 template',
        thumbnail_url: 'http://placehold.it/300x200',
      )

      # categories
      Landable::Category.where(name: 'Uncategorized').first_or_create!(description: 'No category')
      Landable::Category.where(name: 'Affiliates').first_or_create!(description: 'Affiliates')
      Landable::Category.where(name: 'PPC').first_or_create!(description: 'Pay-per-click')
      Landable::Category.where(name: 'SEO').first_or_create!(description: 'Search engine optimization')
    end

    desc 'Seed required data (namely status codes)'
    task :required => :environment do
      # status code categories
      okay = Landable::StatusCodeCategory.where(name: 'okay').first_or_create!
      redirect = Landable::StatusCodeCategory.where(name: 'redirect').first_or_create!
      missing = Landable::StatusCodeCategory.where(name: 'missing').first_or_create!

      # status codes
      Landable::StatusCode.where(code: 200).first_or_create!(description: 'OK', status_code_category: okay)
      Landable::StatusCode.where(code: 301).first_or_create!(description: 'Permanent Redirect', status_code_category: redirect)
      Landable::StatusCode.where(code: 302).first_or_create!(description: 'Temporary Redirect', status_code_category: redirect)
      Landable::StatusCode.where(code: 404).first_or_create!(description: 'Not Found', status_code_category: missing)
    end
  end

  desc 'Seed required and extra data'
  task :seed => ['seed:required', 'seed:extras']
end

desc 'Alias for landable:test'
task :landable => 'landable:test'
