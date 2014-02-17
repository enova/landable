class AddResponseTimeToTrafficPageViews < ActiveRecord::Migration
  def change
    change_table "#{Landable.configuration.schema_prefix}landable_traffic.page_views" do |t|
      t.column :response_time, :integer
    end
  end
end
