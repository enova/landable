class AddHeroAssetToLandablePage < ActiveRecord::Migration
  def change
    add_column "landable.pages", :hero_asset_id, :uuid
  end
end
