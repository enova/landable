BEGIN;

SELECT PLAN(12);

--Verify PK and FK columns
SELECT col_is_fk('landable', 'pages', 'published_revision_id', 'pages have published_revision_id fk');
SELECT col_is_fk('landable', 'pages', 'theme_id', 'pages have theme_id fk');
SELECT col_is_fk('landable', 'pages', 'category_id', 'pages have category_id fk');
SELECT col_is_pk('landable', 'pages', 'page_id', 'page_id is PK');

--Verify valid status codes only
SELECT throws_matching($$INSERT INTO landable.pages (is_publishable, path, status_code) VALUES ('true', '/bad/page', 205)$$, 'violates check constraint');
SELECT lives_ok($$INSERT INTO landable.pages (is_publishable, path, status_code) VALUES ('true', '/good/page1', 200)$$, 'Valid status code 200');
SELECT lives_ok($$INSERT INTO landable.pages (is_publishable, path, status_code) VALUES ('true', '/good/page2', 301)$$, 'Valid status code 301');
SELECT lives_ok($$INSERT INTO landable.pages (is_publishable, path, status_code) VALUES ('true', '/good/page3', 302)$$, 'Valid status code 303');
SELECT lives_ok($$INSERT INTO landable.pages (is_publishable, path, status_code) VALUES ('true', '/good/page4', 404)$$, 'Valid status code 404');

--Verify unique index on path
SELECT throws_matching($$INSERT INTO landable.pages (is_publishable, path, status_code) VALUES ('true', '/good/page4', 404)$$, 'duplicate key value', 'Unique path');
SELECT throws_matching($$INSERT INTO landable.pages (is_publishable, path, status_code) VALUES ('true', '/GOOD/page4', 404)$$, 'duplicate key value', 'Unique path is case-insensitive');

--Verify valid paths
SELECT throws_matching($$INSERT INTO landable.pages (is_publishable, path, status_code) VALUES ('true', 'good/page4', 200)$$, 'violates check', 'valid path');

SELECT * FROM finish()

ROLLBACK;
