BEGIN;

SELECT PLAN(3);

--Verify PK and FK columns
SELECT col_is_pk('landable', 'status_code_categories', 'status_code_category_id', 'status_code_category_id is PK');

--Verify unique index on code
SELECT index_is_unique('landable', 'status_code_categories', 'landable_status_code_categories__u_name', 'name index is unique');

--Verify seed data loaded
SELECT results_eq($$SELECT COUNT(*)::INT FROM landable.status_code_categories$$, $$SELECT 3::INT$$, 'Should have 3 seed records');

SELECT * FROM finish()

ROLLBACK;
