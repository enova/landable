namespace :landable do

  namespace :seed do
    desc 'Populate a landable database with basic categories and themes'
    task :extras => :environment do
      Landable::Seeds.seed(:extras)
    end

    desc 'Seed required data (namely status codes)'
    task :required => :environment do
      Landable::Seeds.seed(:required)
    end
  end

  desc 'Seed required and extra data'
  task :seed => ['seed:required', 'seed:extras']

end
