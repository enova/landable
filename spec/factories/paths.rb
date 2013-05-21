FactoryGirl.define do
  factory :path, class: 'Landable::Path' do
    sequence(:path) { |n| "/path-#{n}" }
    status_code 200
  end
end
