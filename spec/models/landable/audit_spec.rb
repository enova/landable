require 'spec_helper'

describe Landable::Audit do
  describe '#approver' do
    it 'validates presence' do
      audit = build :audit, approver: nil
      audit.should_not be_valid
      audit.errors[:approver].should_not be_blank

      audit.approver = 'Legal Team'
      audit.should be_valid
      audit.errors[:approver].should be_blank
    end
  end
end
