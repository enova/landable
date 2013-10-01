# Stop-gap solution to allow us to keep mission-critical seed data somewhere
# accessible. Not too thrilled about it; refactor away.
module Landable
  module Seeds

    def self.seed key
      method_key = "seed_#{key}".to_sym
      if respond_to? method_key
        send method_key if ActiveRecord::Base.connection.schema_exists? :landable
      else
        raise NotImplementedError, "No seeds for key '#{key}'"
      end
    end

    private

    # Required data.
    def self.seed_required
      # status code categories
      okay = Landable::StatusCodeCategory.where(name: 'okay').first_or_create!
      redirect = Landable::StatusCodeCategory.where(name: 'redirect').first_or_create!
      missing = Landable::StatusCodeCategory.where(name: 'missing').first_or_create!

      # status codes
      Landable::StatusCode.where(code: 200).first_or_create!(description: 'OK', status_code_category: okay)
      Landable::StatusCode.where(code: 301).first_or_create!(description: 'Permanent Redirect', status_code_category: redirect)
      Landable::StatusCode.where(code: 302).first_or_create!(description: 'Temporary Redirect', status_code_category: redirect)
      Landable::StatusCode.where(code: 404).first_or_create!(description: 'Not Found', status_code_category: missing)

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
        thumbnail_url: 'http://placehold.it/300x200',
      )

      Landable::Theme.where(name: 'Minimal').first_or_create!(
        body: File.read(File.expand_path('../../minimal_theme.liquid', __FILE__)),
        description: 'A minimal HTML5 template',
        thumbnail_url: 'http://placehold.it/300x200',
      )
    end

  end
end
