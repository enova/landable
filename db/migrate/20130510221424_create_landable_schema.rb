class CreateLandableSchema < ActiveRecord::Migration
  def change
    create_table 'landable.paths' do |t|
      # bad name; this is probably '/foo' not 'http://...'
      t.text    :url,         null: false
      t.integer :status_code, null: false, default: 200
      t.integer :page_id
      t.timestamps
    end

    add_index 'landable.paths', :url, unique: true

    create_table 'landable.pages' do |t|
      t.text :title
      t.text :body
      t.timestamps
    end

    create_table 'landable.layouts' do |t|
      t.string :name, null: false
      t.timestamps
    end

    create_table 'landable.components' do |t|
      t.string :name, null: false

      # TODO hstore? For now, just serialize a hash like a friggin caveman
      t.text :config
      t.timestamps
    end

    create_table 'landable.components_layouts', id: false do |t|
      t.integer :component_id, null: false
      t.integer :layout_id,    null: false
      t.text :config
      t.timestamps
    end

    add_index 'landable.components_layouts', [:component_id, :layout_id],
      unique: true,
      name: 'index_components_layouts'

    create_table 'landable.components_pages', id: false do |t|
      t.integer :component_id, null: false
      t.integer :page_id,      null: false
      t.text :config
      t.timestamps
    end

    add_index 'landable.components_pages', [:component_id, :page_id],
      unique: true,
      name: 'index_components_pages'
  end
end
