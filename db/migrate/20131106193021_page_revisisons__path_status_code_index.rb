class PageRevisisonsPathStatusCodeIndex < ActiveRecord::Migration
  def up
    execute "DROP INDEX landable.landable_page_revisions__path"
    execute "CREATE INDEX landable_page_revisions__path_status_code ON landable.page_revisions(path, status_code)"
  end
end
