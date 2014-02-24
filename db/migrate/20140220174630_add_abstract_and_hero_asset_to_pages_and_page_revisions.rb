class AddAbstractAndHeroAssetToPagesAndPageRevisions < Landable::Migration
  def change
    add_column 'landable.pages', :abstract, :text
    add_column 'landable.pages', :hero_asset_id, :uuid
    add_column 'landable.page_revisions', :abstract, :text
    add_column 'landable.page_revisions', :hero_asset_id, :uuid
  end
end
