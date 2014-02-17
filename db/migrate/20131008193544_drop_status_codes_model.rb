require_dependency 'landable/page'
class DropStatusCodesModel < Landable::Migration

  class Landable::StatusCode < ActiveRecord::Base
    self.table_name = "#{Landable.configuration.schema_prefix}landable.status_codes"
  end

  def change
    # Add the column
    add_column "#{Landable.configuration.schema_prefix}landable.pages", :status_code, :integer, null: false, default: 200, limit: 2
    add_column "#{Landable.configuration.schema_prefix}landable.page_revisions", :status_code, :integer, limit: 2

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
    execute <<-SQL
      ALTER TABLE #{Landable.configuration.schema_prefix}landable.pages DROP CONSTRAINT status_code_fk;
      ALTER TABLE #{Landable.configuration.schema_prefix}landable.page_revisions DROP CONSTRAINT status_code_id_fk;
      DROP TRIGGER #{Landable.configuration.schema_prefix}landable_page_revisions__no_update 
                    ON #{Landable.configuration.schema_prefix}landable.page_revisions;
      CREATE TRIGGER #{Landable.configuration.schema_prefix}landable_page_revisions__no_update
            BEFORE UPDATE OF notes, is_minor, page_id, author_id, created_at, ordinal
              , theme_id, status_code, category_id, redirect_url, body
            ON #{Landable.configuration.schema_prefix}landable.page_revisions
            FOR EACH STATEMENT EXECUTE PROCEDURE #{Landable.configuration.schema_prefix}landable.tg_disallow();
    SQL

    # Remove tables, columns
    remove_column "#{Landable.configuration.schema_prefix}landable.pages", :status_code_id
    remove_column "#{Landable.configuration.schema_prefix}landable.page_revisions", :status_code_id
    drop_table "#{Landable.configuration.schema_prefix}landable.status_codes"
    drop_table "#{Landable.configuration.schema_prefix}landable.status_code_categories"
  end
end
