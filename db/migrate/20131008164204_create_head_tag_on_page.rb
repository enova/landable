class CreateHeadTagOnPage < Landable::Migration
  def up
    execute "DROP TRIGGER landable_page_revisions__no_update ON landable.page_revisions"

    drop_table    "landable.head_tags"
    remove_column "landable.page_revisions", :head_tags

    add_column    "landable.pages",          :head_content, :text
    add_column    "landable.page_revisions", :head_content, :text

    execute "CREATE TRIGGER landable_page_revisions__no_update
            BEFORE UPDATE OF notes, is_minor, page_id, author_id, created_at, ordinal
              , theme_id, status_code_id, category_id, redirect_url, body
              , title, path, meta_tags, head_content
            ON landable.page_revisions
            FOR EACH STATEMENT EXECUTE PROCEDURE landable.tg_disallow();"
  end
end
