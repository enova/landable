require 'spec_helper'

module Landable
  describe TableName do
    describe '#table_name' do
      it 'should generate the correct table name' do
        expect(Page.send(:table_name)).to eq "#{Landable.configuration.database_schema_prefix}landable.pages"
        expect(PageRevision.send(:table_name)).to eq "#{Landable.configuration.database_schema_prefix}landable.page_revisions"
        expect(Theme.send(:table_name)).to eq "#{Landable.configuration.database_schema_prefix}landable.themes"
      end
    end
  end
end
