class AddDntColumnToVisits < ActiveRecord::Migration
  def change
    change_table 'traffic.visits' do |t|
      t.column :do_not_track, :boolean
    end
  end
end