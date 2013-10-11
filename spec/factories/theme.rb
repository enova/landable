FactoryGirl.define do
  factory :theme, class: 'Landable::Theme' do
    sequence(:name) { |n| "Theme #{n}" }
    description "Factory-generated theme"
    thumbnail_url "http://example.com/bogus-screenshot.png"

    body <<-HTML
    <html>
      <head>{% head %}</head>
      <body><header>header</header><article>{% body %}</article></body>
    </html>
    HTML
  end
end
