require_dependency 'landable/page_revision'
class LandablePageRevisionsBreakOutSnapshot < Landable::Migration
  class Landable
    class PageRevision < ActiveRecord::Base
      store :snapshot_attributes, accessors: [:body]
    end
  end

  def up
    # Setup new columns
    add_column "#{Landable.configuration.database_schema_prefix}landable.page_revisions", :theme_id,                  :uuid
    add_column "#{Landable.configuration.database_schema_prefix}landable.page_revisions", :status_code_id,            :uuid
    add_column "#{Landable.configuration.database_schema_prefix}landable.page_revisions", :category_id,               :uuid
    add_column "#{Landable.configuration.database_schema_prefix}landable.page_revisions", :redirect_url,              :text
    add_column "#{Landable.configuration.database_schema_prefix}landable.page_revisions", :body,                      :text
    add_column "#{Landable.configuration.database_schema_prefix}landable.page_revisions", :title,                     :text
    add_column "#{Landable.configuration.database_schema_prefix}landable.page_revisions", :path,                      :text
    add_column "#{Landable.configuration.database_schema_prefix}landable.page_revisions", :meta_tags,                 :hstore
    add_column "#{Landable.configuration.database_schema_prefix}landable.page_revisions", :head_tags,                 :hstore

    execute <<-SQL
      ALTER TABLE #{Landable.configuration.database_schema_prefix}landable.page_revisions
        ADD CONSTRAINT theme_id_fk FOREIGN KEY(theme_id)
        REFERENCES #{Landable.configuration.database_schema_prefix}landable.themes(theme_id);

      ALTER TABLE #{Landable.configuration.database_schema_prefix}landable.page_revisions
        ADD CONSTRAINT status_code_id_fk FOREIGN KEY(status_code_id)
        REFERENCES #{Landable.configuration.database_schema_prefix}landable.status_codes(status_code_id);

      ALTER TABLE #{Landable.configuration.database_schema_prefix}landable.page_revisions
        ADD CONSTRAINT category_id_fk FOREIGN KEY(category_id)
        REFERENCES #{Landable.configuration.database_schema_prefix}landable.categories(category_id);
      SQL

    # Go through each record and copy snapshot into new, broken-out columns
    Landable::PageRevision.all.each do |rev|
      head_tags = {}
      rev.title = rev.snapshot_attributes['title']
      rev.body = rev.snapshot_attributes['body']
      rev.status_code_id = rev.snapshot_attributes['status_code_id']
      rev.category_id = rev.snapshot_attributes['category_id']
      rev.theme_id = rev.snapshot_attributes['theme_id']
      rev.redirect_url = rev.snapshot_attributes['redirect_url']
      rev.path = rev.snapshot_attributes['path']
      rev.meta_tags = rev.snapshot_attributes['meta_tags']
      rev.snapshot_attributes['head_tags'].each do |tag|
        head_tags[tag['head_tag_id']] = tag['content']
      end
      rev.head_tags = head_tags
      rev.save!
    end

    # Remove snapshot column
    remove_column "#{Landable.configuration.database_schema_prefix}landable.page_revisions", :snapshot_attributes

    execute <<-SQL
      DROP TRIGGER #{Landable.configuration.database_schema_prefix}landable_page_revisions__no_update ON #{Landable.configuration.database_schema_prefix}landable.page_revisions;

      CREATE TRIGGER #{Landable.configuration.database_schema_prefix}landable_page_revisions__no_update
            BEFORE UPDATE OF notes, is_minor, page_id, author_id, created_at, ordinal
              , theme_id, status_code_id, category_id, redirect_url, body
              , title, path, meta_tags, head_tags
            ON #{Landable.configuration.database_schema_prefix}landable.page_revisions
            FOR EACH STATEMENT EXECUTE PROCEDURE #{Landable.configuration.database_schema_prefix}landable.tg_disallow();
    SQL
  end

  def down
    fail ActiveRecord::IrreversibleMigration
  end
end
