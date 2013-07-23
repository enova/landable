namespace :landable do

  desc "Populate a landable database with basic categories and themes"
  task :seed => :environment do

    # themes
    Landable::Theme.where(name: 'Blank').first_or_create!({
      body: '',
      description: 'A completely blank theme; only the page body will be rendered.',
      thumbnail_url: 'http://placehold.it/300x200',
    })

    Landable::Theme.where(name: 'Minimal').first_or_create!({
      body: File.read(File.expand_path('../minimal_theme.liquid', __FILE__)),
      description: 'A minimal HTML5 template',
      thumbnail_url: 'http://placehold.it/300x200',
    })

    # categories
    Landable::Category.create! name: 'Uncategorized', description: 'No category'
    Landable::Category.create! name: 'Affiliates',    description: 'Affiliates'
    Landable::Category.create! name: 'PPC',           description: 'Pay-per-click'
    Landable::Category.create! name: 'SEO',           description: 'Search engine optimization'

  end

end
