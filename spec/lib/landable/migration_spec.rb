require 'spec_helper'

class FirstMigration < Landable::Migration
  def up
    execute 'CREATE SCHEMA test_schema; SET SEARCH_PATH TO test_schema,public;'
  end
end

describe Landable::Migration do
  describe 'migrate' do
    let(:connection) { ActiveRecord::Base.connection }

    before(:each) do 
      ActiveRecord::Base.connection_pool.should_receive(:with_connection).and_yield(connection)
    end

    def connection_search_path
      Landable::Migration.connection_search_path connection
    end

    it 'should reset the search_path to the default schema_search_path' do
      default_search_path = connection_search_path
      FirstMigration.migrate(:up)
      connection_search_path.should == default_search_path
    end
  end
end
