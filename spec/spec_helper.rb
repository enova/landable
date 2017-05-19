ENV['RAILS_ENV'] ||= 'test'

require 'simplecov'
SimpleCov.start 'rails'

require File.expand_path('../dummy/config/environment.rb', __FILE__)
require 'rspec/rails'
require 'factory_girl_rails'
require 'valid_attribute'
require 'pry'
require 'shoulda-matchers'
require 'shoulda/matchers/active_record'
require 'shoulda/matchers/active_model'
require 'faker'
require 'test_after_commit'

# Requires supporting ruby files with custom matchers and macros, etc,
# in spec/support/ and its subdirectories.
Dir[Rails.root.join('../../spec/support/**/*.rb')].each { |f| require f }

# Checks for pending migrations before tests are run.
# If you are not using ActiveRecord, you can remove this line.
ActiveRecord::Migration.check_pending! if defined?(ActiveRecord::Migration)

RSpec.configure do |config|
  config.mock_with :rspec
  config.use_transactional_fixtures = true
  config.infer_base_class_for_anonymous_controllers = false
  config.infer_spec_type_from_file_location!
  config.order = 'random'

  config.include FactoryGirl::Syntax::Methods
  config.include Landable::Spec::CoreHelpers
  config.include Landable::Spec::HttpHelpers, type: :controller

  config.include Shoulda::Matchers::ActiveRecord
  config.extend Shoulda::Matchers::ActiveRecord
  config.include Shoulda::Matchers::ActiveModel
  config.extend Shoulda::Matchers::ActiveModel
end
