FactoryGirl.define do
  factory :access_token, class: 'Landable::AccessToken' do
    association :author, strategy: :build
    permissions { { 'read' => 'true', 'edit' => 'true', 'publish' => 'true' } }
  end

  factory :author, class: 'Landable::Author' do
    sequence(:username) { |n| "trogdor#{n}" }
    sequence(:email)    { |n| "trogdor#{n}@example.com" }
    first_name 'Marley'
    last_name 'Pants'

    factory :author_with_access_tokens, class: 'Landable::Author' do
      transient do
        access_tokens_count 5
      end

      after(:build) do |author, evaluator|
        create_list(:access_token, evaluator.access_tokens_count, author: author)
      end
    end
  end

  #factory :access_token, class: 'Landable::AccessToken' do
    #association :author, strategy: :build
    #permissions { { 'read' => 'true', 'edit' => 'true', 'publish' => 'true' } }
  #end
end
