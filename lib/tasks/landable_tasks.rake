namespace :landable do

  desc "Populate a landable database with basic categories, themes, and layouts"
  task :seed => :environment do

    # themes
    Landable::Theme.where(name: 'Blank').first_or_create!({
      body: '',
      description: 'A completely blank theme; only the page body will be rendered.'
    })

    Landable::Theme.where(name: 'Minimal').first_or_create!({
      body: File.read(File.expand_path('../minimal_theme.liquid', __FILE__)),
      description: 'A minimal HTML5 template'
    })

    # categories
    Landable::Category.create! name: 'Uncategorized', description: 'No category'
    Landable::Category.create! name: 'Affiliates',    description: 'Affiliates'
    Landable::Category.create! name: 'PPC',           description: 'Pay-per-click'
    Landable::Category.create! name: 'SEO',           description: 'Search engine optimization'

    # layouts
    Landable::Layout.create!(
      name:         'Starter',
      description:  'Barebones starter document.',
      body:         File.read(File.expand_path('../starter_layout.html', __FILE__)),
    )
    Landable::Layout.create!(
      name:         'Basic Marketing',
      description:  'Features a hero unit for a primary message and three supporting elements.',
      body:         File.read(File.expand_path('../basic_marketing_layout.html', __FILE__)),
    )

  end

end
