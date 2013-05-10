class CreateLandablePages < ActiveRecord::Migration
  def change
    create_table :landable_pages do |t|
      t.string :title
      t.string :state
      t.text :body

      t.timestamps
    end
  end
end
