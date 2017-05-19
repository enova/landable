require 'spec_helper'

module Landable
  describe HasAssets do
    before(:each) { create_list :asset, 4 }

    let(:assets) { Landable::Asset.first(3) }
    let(:subject) do
      build :page, body: "
          <div>{% img_tag #{assets[0].name} %}</div>
          <div>{% asset_url #{assets[1].name} %}</div>
          <div>{% asset_description #{assets[2].name} %}</div>
          <div>{% img_tag #{assets[0].name} %}</div>
        "
    end

    describe '#assets' do
      it 'should return assets matching #asset_names' do
        result = double
        expect(subject).to receive(:asset_names) { %w(one two three) }
        expect(Landable::Asset).to receive(:where).with(name: %w(one two three)) { result }
        expect(subject.assets).to eq result
      end
    end

    describe '#asset_names' do
      it 'should pull asset names out of the body' do
        expect(subject.asset_names.sort).to eq assets.map(&:name).uniq.sort
      end
    end

    describe '#save_assets!' do
      it 'should save the assets' do
        assets_double = double
        expect(subject).to receive(:assets) { assets_double }
        expect(subject).to receive(:assets=).with(assets_double)
        subject.save_assets!
      end

      it 'should be called during save' do
        expect(subject).to receive :save_assets!
        subject.save!
      end
    end

    describe '#assets_as_hash' do
      it 'should return a hash of asset names to asset instances' do
        subject.save!
        expect(subject.assets_as_hash).to eq Hash[assets.map { |asset| [asset.name, asset] }]
      end
    end

    describe 'body=' do
      it 'should reset the asset_names cache, then set the body' do
        subject.instance_eval { @asset_names = 'foo' }
        subject.body = 'bar'
        expect(subject.body).to eq 'bar'
        expect(subject.instance_eval { @asset_names }).to be_nil
        expect(subject.asset_names).to eq []
      end
    end

    describe '#assets_join_table_name' do
      it 'should generate the correct join_table, and then apologize for doing so' do
        expect(Page.send(:assets_join_table_name)).to eq "#{Landable.configuration.database_schema_prefix}landable.page_assets"
        expect(PageRevision.send(:assets_join_table_name)).to eq "#{Landable.configuration.database_schema_prefix}landable.page_revision_assets"
        expect(Theme.send(:assets_join_table_name)).to eq "#{Landable.configuration.database_schema_prefix}landable.theme_assets"
      end
    end
  end
end
