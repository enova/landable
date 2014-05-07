require 'spec_helper'

class FirstMigration < Landable::Migration
  self.verbose = false
  def up
    execute 'CREATE SCHEMA test_schema; SET SEARCH_PATH TO test_schema,public;'
  end
end

class RegularMigration < ActiveRecord::Migration
  self.verbose = false
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

    context 'Landable::Migration' do
      it 'should reset the search_path to the original schema_search_path' do
        default_search_path = connection_search_path

        connection.schema_search_path = 'public'
        FirstMigration.migrate(:up)
        connection_search_path.should == 'public'

        connection.schema_search_path = default_search_path
      end
    end

    context 'ActiveRecord::Migration' do
      it 'should NOT reset the search_path to the original schema_search_path' do
        connection.schema_search_path = 'public'

        connection_search_path.should == 'public'
        RegularMigration.migrate(:up)
        connection_search_path.should_not == 'public'
      end
    end
  end
end
