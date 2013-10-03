class FileBasedThemes < ActiveRecord::Migration
  def up
    change_table 'landable.themes' do |t|
      t.text    :file
      t.text    :extension
      t.boolean :editable, null: false, default: true
    end

    execute "CREATE UNIQUE INDEX landable_themes__u_file ON landable.themes(lower(file))"
  end
end
