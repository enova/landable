class AddBlogFieldsToLandablePageRevision < ActiveRecord::Migration
  def change
    add_column "landable.page_revisions", :abstract, :text
    add_column "landable.page_revisions", :hero_asset_id, :uuid
  end
end
