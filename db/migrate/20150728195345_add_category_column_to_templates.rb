class AddCategoryColumnToTemplates < ActiveRecord::Migration
  def change
    schema_name = "#{Landable.configuration.database_schema_prefix}landable"

    # add category_id to our templates table.
    add_column "#{schema_name}.templates", :category_id, :uuid
    execute "ALTER TABLE #{schema_name}.templates ADD FOREIGN KEY (category_id) REFERENCES #{schema_name}.categories(category_id)"

    # add category_id to our template_revisions table.
    add_column "#{schema_name}.template_revisions", :category_id, :uuid
    execute "ALTER TABLE #{schema_name}.template_revisions ADD FOREIGN KEY (category_id) REFERENCES #{schema_name}.categories(category_id)"
  end
end
