class CreateLandableSchema < ActiveRecord::Migration
  def change
    enable_extension "uuid-ossp"

    execute "CREATE SCHEMA landable"

    create_table 'landable.pages', id: :uuid, primary_key: :page_id do |t|
      t.text :theme
      t.text :title, null: false
      t.text :body,  null: false
      t.timestamps
    end

    create_table 'landable.paths', id: :uuid, primary_key: :path_id do |t|
      t.text    :path,        null: false
      t.integer :status_code, null: false, default: 200
      t.uuid    :page_id
      t.timestamps
    end

    add_index 'landable.paths', :path, unique: true
  end
end
