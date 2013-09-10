class LandablePagesAddUpdatedBy < ActiveRecord::Migration
  def change
    add_column "landable.pages", :updated_by_author_id, :uuid

    execute "ALTER TABLE landable.pages ADD CONSTRAINT updated_author_fk FOREIGN KEY(updated_by_author_id) REFERENCES landable.authors(author_id)"
  end
end
