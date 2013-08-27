FactoryGirl.define do

  factory :screenshot, class: 'Landable::Screenshot' do
    browser
    browserstack_id { SecureRandom.uuid }
  end

  factory :page_screenshot, parent: :screenshot do
    screenshotable { build :page }
  end

  factory :page_revision_screenshot, parent: :screenshot do
    screenshotable { build :page_revision }
  end

end