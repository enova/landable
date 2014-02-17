class FileBasedThemes < Landable::Migration
  def up
    change_table "#{Landable.configuration.schema_prefix}landable.themes" do |t|
      t.text    :file
      t.text    :extension
      t.boolean :editable, null: false, default: true
    end

    execute "CREATE UNIQUE INDEX #{Landable.configuration.schema_prefix}landable_themes__u_file 
              ON #{Landable.configuration.schema_prefix}landable.themes(lower(file))"
  end
end
