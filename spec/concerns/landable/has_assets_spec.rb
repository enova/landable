require 'spec_helper'

module Landable
  describe HasAssets do

    before(:each) { create_list :asset, 4 }

    let(:assets) { Landable::Asset.first(3) }
    let(:subject) {
      build :page, {
        body: "
          <div>{% img_tag #{assets[0].name} %}</div>
          <div>{% asset_url #{assets[1].name} %}</div>
          <div>{% asset_description #{assets[2].name} %}</div>
          <div>{% img_tag #{assets[0].name} %}</div>
        "
      }
    }

    describe '#assets' do
      it 'should return assets matching #asset_names' do
        result = double()
        subject.should_receive(:asset_names) { ['one', 'two', 'three'] }
        Landable::Asset.should_receive(:where).with(name: ['one', 'two', 'three']) { result }
        subject.assets.should == result
      end
    end

    describe '#asset_names' do
      it 'should pull asset names out of the body' do
        subject.asset_names.sort.should == assets.map(&:name).uniq.sort
      end
    end

    describe '#save_assets!' do
      it 'should save the assets' do
        assets_double = double()
        subject.should_receive(:assets) { assets_double }
        subject.should_receive(:assets=).with(assets_double)
        subject.save_assets!
      end

      it 'should be called during save' do
        subject.should_receive :save_assets!
        subject.save!
      end
    end

    describe '#assets_as_hash' do
      it 'should return a hash of asset names to asset instances' do
        subject.save!
        subject.assets_as_hash.should == Hash[assets.map { |asset| [asset.name, asset] }]
      end
    end

    describe 'body=' do
      it 'should reset the asset_names cache, then set the body' do
        subject.instance_eval { @asset_names = 'foo' }
        subject.body = 'bar'
        subject.body.should == 'bar'
        subject.instance_eval { @asset_names }.should be_nil
        subject.asset_names.should == []
      end
    end

    describe '#assets_join_table_name' do
      it 'should generate the correct join_table, and then apologize for doing so' do
        Page.send(:assets_join_table_name).should == 'landable.page_assets'
        PageRevision.send(:assets_join_table_name).should == 'landable.page_revision_assets'
        Theme.send(:assets_join_table_name).should == 'landable.theme_assets'
      end
    end

  end
end