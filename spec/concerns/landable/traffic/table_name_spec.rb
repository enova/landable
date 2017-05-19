require 'spec_helper'

module Landable
  module Traffic
    describe TableName do
      describe '#table_name' do
        it 'should generate the correct table name' do
          expect(Visit.send(:table_name)).to eq "#{Landable.configuration.database_schema_prefix}landable_traffic.visits"
          expect(PageView.send(:table_name)).to eq "#{Landable.configuration.database_schema_prefix}landable_traffic.page_views"
        end
      end
    end
  end
end
