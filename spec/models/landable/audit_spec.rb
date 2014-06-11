require 'spec_helper'

describe Landable::Audit do
  it { should validate_presence_of(:approver) }
end
