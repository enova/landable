class AddMetaOnEvents < Landable::Migration
  def change
    change_table "#{Landable.configuration.schema_prefix}landable_traffic.events" do |t|
      t.column :meta, :hstore
    end
  end
end
