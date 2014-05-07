class AddAbstractAndHeroAssetToPagesAndPageRevisions < Landable::Migration
  def change
    add_column "#{Landable.configuration.database_schema_prefix}landable.pages", :abstract, :text
    add_column "#{Landable.configuration.database_schema_prefix}landable.pages", :hero_asset_id, :uuid
    add_column "#{Landable.configuration.database_schema_prefix}landable.page_revisions", :abstract, :text
    add_column "#{Landable.configuration.database_schema_prefix}landable.page_revisions", :hero_asset_id, :uuid
  end
end
