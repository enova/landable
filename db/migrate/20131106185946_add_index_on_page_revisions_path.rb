class AddIndexOnPageRevisionsPath < ActiveRecord::Migration
  def up
    execute "CREATE INDEX landable_page_revisions__path ON landable.page_revisions(path)"
  end
end
