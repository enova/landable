class DropBrowserScreenshotTables < ActiveRecord::Migration
  def up
    drop_table    'landable.screenshots'
    drop_table    'landable.browsers'
  end
end