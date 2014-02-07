class AddResponseTimeToTrafficPageViews < ActiveRecord::Migration
  def change
    change_table 'traffic.page_views' do |t|
      t.column :response_time, :integer
    end
  end
end
