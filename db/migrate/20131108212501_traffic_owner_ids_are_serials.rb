class TrafficOwnerIdsAreSerials < Landable::Migration
  def up
    execute <<-SQL
      SET search_path TO traffic,public;

      CREATE SEQUENCE owners_owner_id_seq
        START WITH 1
        INCREMENT BY 1
        NO MINVALUE
        NO MAXVALUE
        CACHE 1;

      SELECT setval('owners_owner_id_seq', (SELECT max(owner_id) FROM owners));

      ALTER SEQUENCE owners_owner_id_seq OWNED BY owners.owner_id;

      ALTER TABLE owners ALTER COLUMN owner_id SET DEFAULT nextval('owners_owner_id_seq'::regclass);
    SQL
  end
end
