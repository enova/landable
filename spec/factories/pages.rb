# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :page, class: 'Landable::Page' do
    association :theme, strategy: :build

    sequence(:path)  { |n| "/page-#{n}" }
    sequence(:title) { |n| "Page #{n}" }

    body "<div>Page body</div>"

    head_content "<link rel='alternate' type='application/rss+xml' title='RSS' href='/rss'>"

    # Anyone see a more reasonable way to unset these attributes?
    trait :redirect do
      status_code_id Landable::StatusCode.where(code: 301).first.id
      redirect_url "/redirect/somewhere/else"

      theme nil
      title nil
      body  nil
    end

    trait :not_found do
      status_code_id Landable::StatusCode.where(code: 404).first.id

      theme nil
      title nil
      body  nil
    end
  end
end
