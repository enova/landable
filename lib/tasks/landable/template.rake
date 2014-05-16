namespace :landable do
  namespace :templates do
    desc 'Publish Any Templates'
    task publish: :environment do
      Landable::Template.find_each do |template|
        template.publish! author: Landable::Author.find_or_create_by(username: 'TrogdorAdmin', email: 'trogdoradming@example.com', first_name: 'Marley', last_name: 'Pants')
      end
    end
  end
end
