BEGIN;

  SELECT PLAN(4);

  SELECT col_is_pk('dummy_landable', 'access_tokens', 'access_token_id', 'access tokens have PK');
  SELECT col_is_fk('dummy_landable', 'access_tokens', 'author_id', 'author_id is FK');

  SELECT col_not_null('dummy_landable', 'access_tokens', 'author_id', 'author_id not null');
  SELECT col_not_null('dummy_landable', 'access_tokens', 'expires_at', 'expires_at not null');

  SELECT * FROM finish();

ROLLBACK;
