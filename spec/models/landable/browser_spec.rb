require 'spec_helper'

module Landable

  describe Browser do

    it { should have_many :screenshots }

    describe '#is_mobile' do
      context 'mobile' do
        it 'should be mobile' do
          build(:browser, device: 'your tablet').is_mobile.should be_true
        end
      end

      context 'not mobile' do
        it 'should not be mobile' do
          build(:browser, device: nil).is_mobile.should be_false
        end
      end
    end

    describe '#browserstack_attributes' do
      it 'returns a hash containing the keys defining the browser' do
        browser = build(:browser)
        browser.browserstack_attributes.keys.sort.should == ['browser', 'browser_version', 'device', 'os', 'os_version']
      end
    end

  end

end