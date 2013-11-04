class AddMetaOnEvents < ActiveRecord::Migration
  def change
    change_table 'traffic.events' do |t|
      t.column :meta, :hstore
    end
  end
end
