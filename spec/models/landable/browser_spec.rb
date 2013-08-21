require 'spec_helper'

module Landable

  describe Browser do

    it { should have_many :screenshots }

    %w[is_mobile mobile?].each do |method|
      describe "##{method}" do
        context 'mobile' do
          it 'should be mobile' do
            build(:browser, device: 'your tablet').send(method).should be_true
          end
        end

        context 'not mobile' do
          it 'should not be mobile' do
            build(:browser, device: nil).send(method).should be_false
          end
        end
      end
    end

    describe '#browserstack_attributes' do
      it 'returns a hash containing the keys defining the browser' do
        browser = build(:browser)
        browser.browserstack_attributes.keys.sort.should == ['browser', 'browser_version', 'device', 'os', 'os_version']
      end
    end

    describe '#name' do
      context 'mobile' do
        let(:browser) { build :browser }

        it 'should be the device' do
          browser.name.should == browser.device
        end
      end

      context 'not mobile' do
        let(:browser) { build :browser, device: nil }

        it 'should be the browser and os info' do
          browser.name.should == "#{browser.browser_name} #{browser.browser_version} (#{browser.os_name} #{browser.os_version})"
        end
      end
    end

  end

end