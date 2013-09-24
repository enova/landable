require_dependency 'landable/page_revision'
class LandablePageRevisionsBreakOutSnapshot < ActiveRecord::Migration

  class Landable::PageRevision < ActiveRecord::Base
    store :snapshot_attributes, accessors: [:body]
  end

  def change

    # Setup new columns
    add_column "landable.page_revisions", :theme_id,       :uuid
    add_column "landable.page_revisions", :status_code_id, :uuid
    add_column "landable.page_revisions", :category_id,    :uuid
    add_column "landable.page_revisions", :redirect_url,   :text
    add_column "landable.page_revisions", :body,           :text
    add_column "landable.page_revisions", :title,          :text
    add_column "landable.page_revisions", :path,           :text
    add_column "landable.page_revisions", :meta_tags,      :hstore
    add_column "landable.page_revisions", :head_tags,      :hstore

    execute "ALTER TABLE landable.page_revisions ADD CONSTRAINT theme_id_fk FOREIGN KEY(theme_id) REFERENCES landable.themes(theme_id)"
    execute "ALTER TABLE landable.page_revisions ADD CONSTRAINT status_code_id_fk FOREIGN KEY(status_code_id) REFERENCES landable.status_codes(status_code_id)"
    execute "ALTER TABLE landable.page_revisions ADD CONSTRAINT category_id_fk FOREIGN KEY(category_id) REFERENCES landable.categories(category_id)"

    # Go through each record and copy snapshot into new, broken-out columns
    Landable::PageRevision.all.each do |rev|
      page = rev.snapshot
      head_tags = {}
      rev.title = page.title
      rev.body = page.body
      rev.status_code_id = page.status_code_id
      rev.category_id = page.category_id
      rev.theme_id = page.theme_id
      rev.redirect_url = page.redirect_url
      rev.path = page.path
      page.head_tags.each do |tag|
        head_tags ||= tag.attributes
      end
      rev.head_tags = head_tags
      rev.save!
    end

    # Remove snapshot column
    remove_column "landable.page_revisions", :snapshot_attributes

    execute "DROP TRIGGER landable_page_revisions__no_update ON landable.page_revisions"

    execute "CREATE TRIGGER landable_page_revisions__no_update
            BEFORE UPDATE OF notes, is_minor, page_id, author_id, created_at, ordinal
              , theme_id, status_code_id, category_id, redirect_url, body
              , title, path, meta_tags, head_tags 
            ON landable.page_revisions
            FOR EACH STATEMENT EXECUTE PROCEDURE landable.tg_disallow();"

  end
end
