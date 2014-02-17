class AddMetaOnEvents < Landable::Migration
  def change
    change_table "#{Landable.configuration.database_schema_prefix}landable_traffic.events" do |t|
      t.column :meta, :hstore
    end
  end
end
