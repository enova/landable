FactoryGirl.define do
  factory :audit, class: 'Landable::Audit' do
    approver 'Marley Pants'
    notes 'you got served!'
    flags ['FCA', 'OFT']
  end
end
