# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :page, class: 'Landable::Page' do
    association :theme, strategy: :build
    association :category

    sequence(:path)  { |n| "/page-#{n}" }
    sequence(:title) { |n| "Page #{n}" }

    body "<div>Page body</div>"

    head_content "<link rel='alternate' type='application/rss+xml' title='RSS' href='/rss'>"

    # Anyone see a more reasonable way to unset these attributes?
    trait :redirect do
      status_code 301
      redirect_url "http://www.redirect.com"

      theme nil
      title nil
      body  nil
    end

    trait :gone do
      status_code 410

      theme nil
      title nil
      body  nil
    end
  end
end
