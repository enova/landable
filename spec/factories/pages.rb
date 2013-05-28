# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :page, class: 'Landable::Page' do
    sequence(:path) { |n| "/page-#{n}" }
    status_code 200

    theme_name 'Foo'
    sequence(:title) { |n| "Page #{n}" }
    body "<div>Page body</div>"

    # Anyone see a more reasonable way to unset these attributes?
    trait :redirect do
      status_code  301
      redirect_url "/redirect/somewhere/else"

      theme_name nil
      title nil
      body nil
    end

    trait :not_found do
      status_code 404

      theme_name nil
      title nil
      body nil
    end
  end
end
