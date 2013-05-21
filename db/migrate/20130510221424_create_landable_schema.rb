class CreateLandableSchema < ActiveRecord::Migration
  def change
    enable_extension "uuid-ossp"

    execute " DROP DOMAIN IF EXISTS uri;
              CREATE DOMAIN uri AS TEXT
              CHECK(
                VALUE ~ '^/[a-zA-Z0-9/_.~-]*$'
              );"

    execute "DROP SCHEMA IF EXISTS landable; CREATE SCHEMA landable;"

    create_table 'landable.pages', id: :uuid, primary_key: :page_id do |t|
      t.column "path", :uri, null: false
      t.text :theme_name

      t.text :title
      t.text :body

      t.integer :status_code, null: false, default: 200
      t.text    :redirect_url

      t.timestamps
    end

    add_index 'landable.pages', :path, unique: true
  end
end
