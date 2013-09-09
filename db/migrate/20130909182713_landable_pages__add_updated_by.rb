class LandablePagesAddUpdatedBy < ActiveRecord::Migration
  def change
    add_column "landable.pages", :updated_by_author_id, :uuid
  end
end
