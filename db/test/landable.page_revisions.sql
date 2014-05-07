BEGIN;

SELECT PLAN(18);

--Verify existence of triggers and functions for page revisions
SELECT triggers_are('dummy_landable', 'page_revisions', ARRAY['dummy_landable_page_revisions__bfr_insert', 'dummy_landable_page_revisions__no_delete', 'dummy_landable_page_revisions__no_update'], 'dummy_landable.page_revisions should have triggers');
SELECT functions_are('dummy_landable', ARRAY['pages_revision_ordinal', 'tg_disallow'], 'dummy_Landable schema should have funcitons');

--Verify existence of foreign keys
SELECT col_is_fk('dummy_landable', 'page_revisions', 'page_id', 'page_revisions has page_id foreign key');
SELECT col_is_fk('dummy_landable', 'page_revisions', 'author_id', 'page_revisions has author_id foreign key');
SELECT col_is_fk('dummy_landable', 'page_revisions', 'theme_id', 'page_revisions has theme_id foreign key');
SELECT col_is_fk('dummy_landable', 'page_revisions', 'category_id', 'page_revisions has category_id foreign key');

--Verify primary key
SELECT col_is_pk('dummy_landable', 'page_revisions', 'page_revision_id', 'page_revisions has primary key');

--Insert test data
SELECT lives_ok($$INSERT INTO dummy_landable.pages (is_publishable, path, status_code) VALUES ('true', '/foo/bar', 200)$$);
SELECT lives_ok($$INSERT INTO dummy_landable.authors (email, username, first_name, last_name) VALUES ('jdoe@test.com', 'jdoe', 'john', 'doe')$$);
SELECT lives_ok($$INSERT INTO dummy_landable.page_revisions(page_id, author_id) SELECT page_id, author_id FROM dummy_landable.pages, dummy_landable.authors$$);

--Verify ordinal is generated and populated automatically
SELECT results_eq($$SELECT max(ordinal) FROM dummy_landable.page_revisions$$, $$SELECT 1$$);

--Verify ordinal is incremented automatically
SELECT lives_ok($$INSERT INTO dummy_landable.page_revisions(page_id, author_id) SELECT page_id, author_id FROM dummy_landable.pages, dummy_landable.authors$$);
SELECT results_eq($$SELECT max(ordinal) FROM dummy_landable.page_revisions$$, $$SELECT 2$$);

--Verify ordinals cannot be supplied in insert
SELECT throws_matching($$INSERT INTO dummy_landable.page_revisions(ordinal, page_id, author_id) SELECT 1, page_id, author_id FROM dummy_landable.pages, dummy_landable.authors$$, 'ordinal');

--Verify cannot delete from page_revisions
SELECT throws_matching($$DELETE FROM dummy_landable.page_revisions$$, 'DELETEs are not allowed');

--Verify cannot update fields others than is_published, updated_atfor page_revisions
SELECT throws_matching($$UPDATE dummy_landable.page_revisions SET notes = 'blah'$$, 'UPDATEs are not allowed', 'Cannot update notes');
SELECT lives_ok($$UPDATE dummy_landable.page_revisions SET updated_at = now()$$, 'Can update updated_at');
SELECT lives_ok($$UPDATE dummy_landable.page_revisions SET is_published = 'true'$$, 'Can update is_published');

ROLLBACK;
