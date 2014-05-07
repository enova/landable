FactoryGirl.define do
  factory :category, class: 'Landable::Category' do
    sequence(:name) { |n| "Category #{n}" }
    description "Factory-generated category"
  end
end
