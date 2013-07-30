BEGIN;
  SELECT PLAN(10);

  SELECT col_not_null('landable', 'authors', 'email', 'email is not null');
  SELECT col_not_null('landable', 'authors', 'username', 'usernameis not null');
  SELECT col_not_null('landable', 'authors', 'first_name', 'first_name is not null');
  SELECT col_not_null('landable', 'authors', 'last_name', 'last_name is not null');

  SELECT col_is_pk('landable', 'authors', 'author_id', 'author_id is PK');

  --Verify unique index on email
  SELECT lives_ok($$INSERT INTO landable.authors (email, username, first_name, last_name) VALUES ('jdoe@test.com', 'jdoe', 'john', 'doe')$$);
  SELECT throws_matching($$INSERT INTO landable.authors (email, username, first_name, last_name) VALUES ('jdoe@test.com', 'jdoe', 'john', 'doe')$$, 'violates unique constraint');
  SELECT throws_matching($$INSERT INTO landable.authors (email, username, first_name, last_name) VALUES ('JDOE@test.com', 'jdoe', 'john', 'doe')$$, 'violates unique constraint', 'email is case insensitive');

  --Verify unique index on username
  SELECT throws_matching($$INSERT INTO landable.authors (email, username, first_name, last_name) VALUES ('jdoe2@test.com', 'jdoe', 'john', 'doe')$$, 'violates unique constraint', 'unique username');
  SELECT lives_ok($$INSERT INTO landable.authors (email, username, first_name, last_name) VALUES ('jdoe2@test.com', 'JDoe', 'john', 'doe')$$, 'unique username is case insensitive');

  SELECT * FROM finish();

ROLLBACK;
