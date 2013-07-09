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

  factory :template, class: 'Landable::Template' do
    sequence(:name) { |n| "Template #{n}" }
    description "Factory-generated template"
    screenshot_url "http://example.com/bogus-screenshot.png"
    body '<div class="container">content goes here!</div>'
  end

  factory :category, class: 'Landable::Category' do
    sequence(:name) { |n| "Category #{n}" }
    description "Factory-generated category"
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

  factory :asset, class: 'Landable::Asset' do
    ignore do
      asset_dir    { Landable::Engine.root.join('spec', 'fixtures', 'assets') }
      all_fixtures { ['panda.png', 'cthulhu.jpg', 'small.pdf', 'sloth.png'] }

      sequence(:fixture) do
        taken = Landable::Asset.pluck(:basename)
        all_fixtures.find { |name| !taken.include?(name) }.tap do |available|
          raise "Add more files to spec/fixtures/assets; we've only got #{all_fixtures.length} available." if available.nil?
        end
      end
    end

    sequence(:name)        { |n| "asset upload #{n}" }
    sequence(:description) { |n| "what a useful asset #{n}" }
    author

    data do
      path = File.join asset_dir, fixture
      mime = case path
             when /\.png$/   then 'image/png'
             when /\.jpe?g$/ then 'image/jpeg'
             when /\.pdf$/   then 'application/pdf'
             end
      Rack::Test::UploadedFile.new(path, mime)
    end
  end
end
