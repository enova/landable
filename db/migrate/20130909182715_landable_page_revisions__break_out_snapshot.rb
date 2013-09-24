class LandablePageRevisionsBreakOutSnapshot < ActiveRecord::Migration
  def change

    # Setup new columns
    add_column "landable.page_revision", :theme_id,       :uuid
    add_column "landable.page_revision", :status_code_id, :uuid
    add_column "landable.page_revision", :category_id,    :uuid
    add_column "landable.page_revision", :redirect_url,   :text
    add_column "landable.page_revision", :body,           :text
    add_column "landable.page_revision", :title,          :text
    add_column "landable.page_revision", :path,           :text
    add_column "landable.page_revision", :meta_tags,      :hstore

    execute "ALTER TABLE landable.page_revisions ADD CONSTRAINT theme_id_fk FOREIGN KEY(theme_id) REFERENCES landable.themes(theme_id)"
    execute "ALTER TABLE landable.page_revisions ADD CONSTRAINT status_code_id_fk FOREIGN KEY(status_code_id) REFERENCES landable.status_codes(status_code_id)"
    execute "ALTER TABLE landable.page_revisions ADD CONSTRAINT category_id_fk FOREIGN KEY(category_id) REFERENCES landable.categories(category_id)"

    class Landable::PageRevision
      store :snapshot_attributes, accessors: [:body]
    end

    # Go through each record and copy snapshot into new, broken-out columns
    Landable::PageRevision.each do |rev|
      page = Landable::Page.new rev.snapshot
      rev.title = page.title
      rev.body = page.body
      rev.status_code_id = page.status_code_id
      rev.category_id = page.category_id
      rev.theme_id = page.theme_id
      rev.redirect_url = page.redirect_url
      rev.path = page.path
      rev.save!
    end

    # Remove snapshot column
    remove_column "landable.page_revisions", :snapshot_attributes

    # TODO: Create triggers preventing the sort of updates we just did :)

  end
end
