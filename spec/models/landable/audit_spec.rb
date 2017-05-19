require 'spec_helper'

describe Landable::Audit do
  it { is_expected.to validate_presence_of(:approver) }
end
