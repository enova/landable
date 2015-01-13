class AddPageNameToPage < ActiveRecord::Migration
  def change
    add_column "#{Landable.configuration.database_schema_prefix}landable.pages", :page_name, :string
  end
end
