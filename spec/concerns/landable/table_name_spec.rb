require 'spec_helper'

module Landable
  describe TableName do
    describe '#table_name' do
      it 'should generate the correct table name' do
        Page.send(:table_name).should eq "#{Landable.configuration.database_schema_prefix}landable.pages"
        PageRevision.send(:table_name).should eq "#{Landable.configuration.database_schema_prefix}landable.page_revisions"
        Theme.send(:table_name).should eq "#{Landable.configuration.database_schema_prefix}landable.themes"
      end
    end
  end
end
