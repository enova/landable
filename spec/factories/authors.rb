FactoryGirl.define do
  factory :author, class: 'Landable::Author' do
    sequence(:username) { |n| "trogdor#{n}" }
    sequence(:email)    { |n| "trogdor#{n}@example.com" }
    first_name 'Marley'
    last_name  'Pants'
  end

  factory :access_token, class: 'Landable::AccessToken' do
    association :author, strategy: :build
  end
end
