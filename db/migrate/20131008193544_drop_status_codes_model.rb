require_dependency 'landable/page'
class DropStatusCodesModel < ActiveRecord::Migration

  class Landable::StatusCodeCategory < ActiveRecord::Base
    self.table_name = "landable.status_code_categories"
    has_many :status_codes, inverse_of: :status_code_category
  end

  class Landable::StatusCode < ActiveRecord::Base
    self.table_name = "landable.status_codes"
    has_many :page, inverse_of: :status_code
    belongs_to :status_code_category, class_name: 'Landable::StatusCodeCategory'
  end

  class Landable::Page < ActiveRecord::Base
    self.table_name = "landable.pages"
    has_one :status_code
  end

  def change
    # Add the column
    add_column "landable.pages", :status_code, :integer, null: false, default: 200, limit: 2
    add_column "landable.page_revisions", :status_code, :integer, limit: 2

    # Backfill existing pages
    Landable::Page.all.each do |page|
      page.status_code = Landable::StatusCode.where(id: page.status_code_id).first.code
    end

    # Backfill existing pages
    Landable::PageRevision.all.each do |page|
      rev.status_code = Landable::StatusCode.where(id: rev.status_code_id).first.code
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
