class JoinTableTemplatesPages < ActiveRecord::Migration
  def change
    create_table "#{Landable.configuration.database_schema_prefix}landable.page_templates", id: :uuid, primary_key: :page_template_id do |t|
      t.uuid :page_id,       null: false
      t.uuid :template_id,   null: false
    end
  end
end
