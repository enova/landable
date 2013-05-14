# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :landable_page, :class => 'Landable::Page' do
    title "MyString"
    state "MyString"
    body "MyText"
  end
end
