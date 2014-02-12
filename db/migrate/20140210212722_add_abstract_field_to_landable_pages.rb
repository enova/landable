class AddAbstractFieldToLandablePages < ActiveRecord::Migration
  def change
    add_column "landable.pages", :abstract, :text
  end
end
