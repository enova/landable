BEGIN;

  SELECT PLAN(5);

  SELECT col_is_pk('landable', 'access_tokens', 'access_token_id', 'access tokens have PK');
  SELECT col_is_fk('landable', 'access_tokens', 'author_id', 'author_id is FK');

  SELECT col_not_null('landable', 'access_tokens', 'author_id', 'author_id not null');
  SELECT col_not_null('landable', 'access_tokens', 'expires_at', 'expires_at not null');

  SELECT indexes_are('landable', 'access_tokens', ARRAY['landable_access_tokens__author_id', 'access_tokens_pkey']);

  SELECT * FROM finish();

ROLLBACK;
