FactoryGirl.define do
  factory :asset, class: 'Landable::Asset' do
    ignore do
      asset_dir    { Landable::Engine.root.join('spec', 'fixtures', 'assets') }
      all_fixtures { ['panda.png', 'cthulhu.jpg', 'small.pdf', 'sloth.png'] }

      sequence(:fixture) do
        taken = Landable::Asset.pluck(:data)
        all_fixtures.find { |name| !taken.include?(name) }.tap do |available|
          raise "Add more files to spec/fixtures/assets; we've only got #{all_fixtures.length} available." if available.nil?
        end
      end
    end

    sequence(:name)        { |n| "asset_upload_#{n}" }
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