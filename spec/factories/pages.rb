# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :theme, class: 'Landable::Theme' do
    sequence(:name) { |n| "Theme #{n}" }
    description "Factory-generated theme"
    screenshot_url "http://example.com/bogus-screenshot.png"

    body <<-HTML
    <html>
      <head>{% title_tag %}{% meta_tags %}</head>
      <body><header>header</header><article>{{body}}</article></body>
    </html>
    HTML
  end

  factory :page, class: 'Landable::Page' do
    association :theme, strategy: :build

    sequence(:path)  { |n| "/page-#{n}" }
    sequence(:title) { |n| "Page #{n}" }

    status_code 200
    body "<div>Page body</div>"

    # Anyone see a more reasonable way to unset these attributes?
    trait :redirect do
      status_code  301
      redirect_url "/redirect/somewhere/else"

      theme nil
      title nil
      body  nil
    end

    trait :not_found do
      status_code 404

      theme nil
      title nil
      body  nil
    end
  end
end
