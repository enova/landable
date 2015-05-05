class LandablePagesAddUpdatedBy < Landable::Migration
  def change
    add_column "#{Landable.configuration.database_schema_prefix}landable.pages", :updated_by_author_id, :uuid

    execute <<-SQL
      ALTER TABLE #{Landable.configuration.database_schema_prefix}landable.pages
      ADD CONSTRAINT updated_author_fk FOREIGN KEY(updated_by_author_id)
      REFERENCES #{Landable.configuration.database_schema_prefix}landable.authors(author_id)
    SQL
  end
end
