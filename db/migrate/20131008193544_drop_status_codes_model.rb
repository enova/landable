require_dependency 'landable/page'
class DropStatusCodesModel < Landable::Migration

  class Landable::StatusCode < ActiveRecord::Base
    self.table_name = "landable.status_codes"
  end

  def change
    # Add the column
    add_column "landable.pages", :status_code, :integer, null: false, default: 200, limit: 2
    add_column "landable.page_revisions", :status_code, :integer, limit: 2

    # Backfill existing pages
    Landable::Page.all.each do |page|
      page.status_code = Landable::StatusCode.where(status_code_id: page.status_code_id).first.code
      page.save!
    end

    # Backfill existing pages
    Landable::PageRevision.all.each do |rev|
      rev.status_code = Landable::StatusCode.where(status_code_id: rev.status_code_id).first.code
      rev.save!
    end

    # Remove constraints, update trigger
    execute "ALTER TABLE landable.pages DROP CONSTRAINT status_code_fk"
    execute "ALTER TABLE landable.page_revisions DROP CONSTRAINT status_code_id_fk"
    execute "DROP TRIGGER landable_page_revisions__no_update ON landable.page_revisions"
    execute "CREATE TRIGGER landable_page_revisions__no_update
            BEFORE UPDATE OF notes, is_minor, page_id, author_id, created_at, ordinal
              , theme_id, status_code, category_id, redirect_url, body
            ON landable.page_revisions
            FOR EACH STATEMENT EXECUTE PROCEDURE landable.tg_disallow();"

    # Remove tables, columns
    remove_column "landable.pages", :status_code_id
    remove_column "landable.page_revisions", :status_code_id
    drop_table "landable.status_codes"
    drop_table "landable.status_code_categories"
  end
end
