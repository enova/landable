namespace :landable do
  namespace :seed do
    desc 'Seed extra data (starter themes)'
    task extras: :environment do
      Landable::Seeds.seed(:extras)
    end

    desc 'Seed required data (categories)'
    task required: :environment do
      Landable::Seeds.seed(:required)
    end
  end

  desc 'Seed required and extra data'
  task seed: ['seed:required', 'seed:extras']
end
