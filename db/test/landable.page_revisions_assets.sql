BEGIN;

  SELECT PLAN(6);

  SELECT col_is_pk('landable', 'page_revision_assets', 'page_revision_asset_id', 'page_revision_assets has PK');

  SELECT col_not_null('landable', 'page_revision_assets', 'asset_id', 'asset_id not null');
  SELECT col_not_null('landable', 'page_revision_assets', 'page_revision_id', 'page_revision_id not null');
  
  SELECT indexes_are('landable', 'page_revision_assets', ARRAY['landable_page_revision_assets__u_page_revision_id_asset_id', 'page_revision_assets_pkey'], 'Indexes exist');

  SELECT col_is_fk('landable', 'page_revision_assets', 'asset_id', 'asset_id is fk');
  SELECT col_is_fk('landable', 'page_revision_assets', 'page_revision_id', 'page_revision_id is fk');

  SELECT * FROM finish();

ROLLBACK;
