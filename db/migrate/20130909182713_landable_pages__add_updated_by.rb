class LandablePagesAddUpdatedBy < ActiveRecord::Migration
  def change
    add_column "landable.pages", :updating_author_id, :uuid
  end
end
