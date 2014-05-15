BEGIN;

SELECT PLAN(18);

--Verify existence of triggers and functions for page revisions
SELECT triggers_are('dummy_landable', 'template_revisions', ARRAY['dummy_landable_template_revisions__bfr_insert', 'dummy_landable_template_revisions__no_delete', 'dummy_landable_template_revisions__no_update'], 'dummy_landable.template_revisions should have triggers');

SELECT col_is_pk('dummy_landable', 'templates', 'template_id', 'Template_id is pk');
SELECT col_not_null('dummy_landable', 'templates', 'name', 'name is NOT NULL');
SELECT col_not_null('dummy_landable', 'templates', 'body', 'body is NOT NULL');
SELECT col_not_null('dummy_landable', 'templates', 'description', 'description is NOT NULL');

SELECT has_index('dummy_landable', 'templates', 'dummy_landable_templates__u_name', 'Index on name');
SELECT index_is_unique('dummy_landable', 'templates', 'dummy_landable_templates__u_name', 'name index is unique');

--Insert test data
SELECT lives_ok($$INSERT INTO dummy_landable.templates (name, slug, body, description) VALUES ('template1', 'template1', 'body1', 'test_body')$$);
SELECT lives_ok($$INSERT INTO dummy_landable.authors (email, username, first_name, last_name) VALUES ('jtemplate@test.com', 'jtemplate', 'john', 'template')$$);
SELECT lives_ok($$INSERT INTO dummy_landable.template_revisions(template_id, author_id, name) SELECT template_id, author_id, a.name FROM dummy_landable.templates a, dummy_landable.authors b WHERE a.name = 'template1' AND b.email = 'jtemplate@test.com' LIMIT 1$$);

--Verify ordinal is generated and populated automatically
SELECT results_eq($$SELECT max(ordinal) FROM dummy_landable.template_revisions WHERE name = 'template1' $$, $$SELECT 1$$);

--Verify ordinal is incremented automatically
SELECT lives_ok($$INSERT INTO dummy_landable.template_revisions(template_id, author_id, name) SELECT template_id, author_id, a.name FROM dummy_landable.templates a, dummy_landable.authors b WHERE a.name = 'template1' AND b.email = 'jtemplate@test.com' LIMIT 1$$);
SELECT results_eq($$SELECT max(ordinal) FROM dummy_landable.template_revisions WHERE name = 'template1'$$, $$SELECT 2$$);

--Verify ordinals cannot be supplied in insert
SELECT throws_matching($$INSERT INTO dummy_landable.template_revisions(ordinal, template_id, author_id) SELECT 1, template_id, author_id FROM dummy_landable.templates, dummy_landable.authors$$, 'ordinal');

--Verify cannot delete from template_revisions
SELECT throws_matching($$DELETE FROM dummy_landable.template_revisions$$, 'DELETEs are not allowed');

--Verify cannot update fields others than is_published, updated_atfor template_revisions
SELECT throws_matching($$UPDATE dummy_landable.template_revisions SET notes = 'blah'$$, 'UPDATEs are not allowed', 'Cannot update notes');
SELECT lives_ok($$UPDATE dummy_landable.template_revisions SET updated_at = now()$$, 'Can update updated_at');
SELECT lives_ok($$UPDATE dummy_landable.template_revisions SET is_published = 'true'$$, 'Can update is_published');


SELECT * FROM finish();

ROLLBACK;
