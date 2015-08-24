FactoryGirl.define do
  factory :access_token, class: 'Landable::AccessToken' do
    association :author, strategy: :create
    permissions { { 'read' => 'true', 'edit' => 'true', 'publish' => 'true' } }
  end

  factory :author, class: 'Landable::Author' do
    sequence(:username) { |n| "trogdor#{n}" }
    sequence(:email)    { |n| "trogdor#{n}@example.com" }
    first_name 'Marley'
    last_name 'Pants'

    ignore do
      tokens_count 1
    end

    after(:create) do |author, evaluator|
      create_list(:access_token, evaluator.tokens_count, author: author)
    end
  end

  factory :author_without_access_tokens, class: 'Landable::Author' do
    sequence(:username) { |n| "trogdor#{n}" }
    sequence(:email)    { |n| "trogdor#{n}@example.com" }
    first_name 'Marley'
    last_name 'Pants'
  end
end
