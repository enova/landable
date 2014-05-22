BEGIN;

SELECT plan(1);

SELECT functions_are('dummy_landable', ARRAY['pages_revision_ordinal', 'tg_disallow', 'template_revision_ordinal'], 'dummy_Landable schema should have funcitons');

SELECT finish();

ROLLBACK;
