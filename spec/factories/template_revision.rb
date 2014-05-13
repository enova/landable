FactoryGirl.define do
  factory :template_revision, class: 'Landable::TemplateRevision' do
    association :template, strategy: :build
    association :author, strategy: :build
  end
end
