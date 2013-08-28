FactoryGirl.define do
  factory :head_tag, class: 'Landable::HeadTag' do
    content '<meta name="keywords" content="test">'
    association :page, factory: :page
  end
end
