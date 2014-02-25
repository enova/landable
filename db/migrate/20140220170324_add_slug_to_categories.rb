class AddSlugToCategories < Landable::Migration
  def up
    add_column "#{Landable.configuration.database_schema_prefix}landable.categories", :slug, :text, unique: true

    Landable::Category.reset_column_information
    Landable::Category.all.each &:save!

    change_column "#{Landable.configuration.database_schema_prefix}landable.categories", :slug, :text, null: false
  end

  def down
    remove_column "#{Landable.configuration.database_schema_prefix}landable.categories", :slug
  end
end
