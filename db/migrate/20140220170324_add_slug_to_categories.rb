class AddSlugToCategories < Landable::Migration
  def up
    add_column 'landable.categories', :slug, :text, unique: true

    Landable::Category.reset_column_information
    Landable::Category.all.each &:save!

    change_column 'landable.categories', :slug, :text, null: false
  end

  def down
    remove_column 'landable.categories', :slug
  end
end
