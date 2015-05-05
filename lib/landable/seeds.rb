# Stop-gap solution to allow us to keep mission-critical seed data somewhere
# accessible. Not too thrilled about it; refactor away.
module Landable
  module Seeds
    def self.seed(key)
      method_key = "seed_#{key}".to_sym
      if respond_to? method_key
        send method_key if ActiveRecord::Base.connection.schema_exists? "#{Landable.configuration.database_schema_prefix}landable"
      else
        fail NotImplementedError, "No seeds for key '#{key}'"
      end
    end

    private

    # Required data.
    def self.seed_required
      # categories ('Uncategorized' is mandatory)
      Landable::Category.where(name: 'Uncategorized').first_or_create!
      Landable.configuration.categories.each do |category_name, category_description|
        Landable::Category.where(name: category_name).first_or_create!(description: category_description)
      end
    end

    # Less required data.
    def self.seed_extras
      # themes
      Landable::Theme.where(name: 'Blank').first_or_create!(
        body: '',
        description: 'A completely blank theme; only the page body will be rendered.',
        thumbnail_url: 'http://placehold.it/300x200'
      )
    end
  end
end
