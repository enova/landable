require 'spec_helper'

describe Landable::Configuration do

  describe 'traffic_enabled' do
    it 'should allow :all, true, false, :html' do
      [:all, true, false, :html].each do |val|
        expect { subject.traffic_enabled = val }.to_not raise_error
        subject.traffic_enabled.should == val
      end
    end

    it 'should not allow bogus values' do
      ['foo', 'baz', 'all', 'false'].each do |val|
        expect { subject.traffic_enabled = val }.to raise_error(ArgumentError, 'Landable::Configuration#traffic_enabled accepts false, true, :all or :html')
      end
    end
  end

end
