FactoryGirl.define do
  factory :page_revision, class: 'Landable::PageRevision' do
    association :page, strategy: :build
    association :author, strategy: :build
  end
end