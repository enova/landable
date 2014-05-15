class AddScreenshotToRevisionsTables < ActiveRecord::Migration
  def change
    add_column "#{Landable.configuration.database_schema_prefix}landable.page_revisions", :screenshot, :text
    add_column "#{Landable.configuration.database_schema_prefix}landable.template_revisions", :screenshot, :text
  end
end
