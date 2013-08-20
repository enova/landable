FactoryGirl.define do
  factory :browser, class: 'Landable::Browser' do
    device nil
    os { Faker::Lorem.word }
    os_version { Random.rand 100 }
    browser { Faker::Lorem.word }
    browser_version { Random.rand 100 }
  end
end