class LandablePagesAddLockVersion < ActiveRecord::Migration
  def change
    add_column "landable.pages", :lock_version, :integer, default: 0, null: false
  end
end
