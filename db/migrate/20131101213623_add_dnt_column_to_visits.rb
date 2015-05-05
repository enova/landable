class AddDntColumnToVisits < Landable::Migration
  def change
    change_table "#{Landable.configuration.database_schema_prefix}landable_traffic.visits" do |t|
      t.column :do_not_track, :boolean
    end
  end
end
