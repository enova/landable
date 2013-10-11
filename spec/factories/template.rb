FactoryGirl.define do
  factory :template, class: 'Landable::Template' do
    sequence(:name) { |n| "Template #{n}" }
    description "Factory-generated template"
    thumbnail_url "http://example.com/bogus-screenshot.png"
    body '<div class="container">content goes here!</div>'
  end
end
