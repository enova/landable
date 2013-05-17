class CreateLandableSchema < ActiveRecord::Migration
  def change
    enable_extension "uuid-ossp"

    execute "CREATE SCHEMA landable"

    create_table 'landable.layouts', id: :uuid, primary_key: :layout_id do |t|
      t.string :name, null: false
      t.text   :body, null: false
      t.timestamps
    end

    create_table 'landable.paths', id: :uuid, primary_key: :path_id do |t|
      # bad name; this is probably '/foo' not 'http://...'
      t.text    :url,         null: false
      t.integer :status_code, null: false, default: 200
      t.uuid    :page_id
      t.timestamps
    end

    add_index 'landable.paths', :url, unique: true

    create_table 'landable.pages', id: :uuid, primary_key: :page_id do |t|
      t.uuid :layout_id
      t.text :title, null: false
      t.text :body,  null: false
      t.timestamps
    end

    create_table 'landable.components', id: :uuid, primary_key: :component_id do |t|
      t.string :name, null: false

      # TODO hstore? For now, just serialize a hash like a friggin caveman
      t.text :config
      t.timestamps
    end

    create_table 'landable.components_layouts', id: false do |t|
      t.uuid :component_id, null: false
      t.uuid :layout_id,    null: false
      t.text :config
      t.timestamps
    end

    add_index 'landable.components_layouts', [:component_id, :layout_id],
      unique: true,
      name: 'index_components_layouts'

    create_table 'landable.components_pages', id: false do |t|
      t.uuid :component_id, null: false
      t.uuid :page_id,      null: false
      t.text :config
      t.timestamps
    end

    add_index 'landable.components_pages', [:component_id, :page_id],
      unique: true,
      name: 'index_components_pages'
  end
end
