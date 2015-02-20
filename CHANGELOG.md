# Changelog

See README.md before updating this file.

## Unreleased [#](https://github.com/enova/landable/compare/v1.12.1...master)

## 1.12.2 [#](https://github.com/enova/landable/compare/v1.12.1...v1.12.2)
* BugFix: Exclude Unpublished Pages from Sitemap [#45]
* Refactor: Adding a gemrc config file [#46]
* BugFix: Fix pg uuid extension migration error [#32, #49]

## 1.12.1 [#](https://github.com/enova/landable/compare/v1.11.1...v1.12.1)
* Feature: Preview For Templates [#44]
* Refactor: Clean Up MetaTags Decorator [#41]
* Feature: Show which Pages a Template Lives On [#43]
* BugFix: Deleted templates not rendered in page [#42]

## 1.11.1 [#](https://github.com/enova/landable/compare/v1.11.0...v1.11.1)
* Feature: Adding PageName [#39]
* BugFix: Force Template Slug to not have a space [#40]

## 1.11.0 [#](https://github.com/enova/landable/compare/v1.10.0.rc1...v1.11.0)
* Feature: Make the tracker.user_agent accessible [#33]
* Refactor: Add missing functions/triggers to schema_move task.  Make it a little better in other ways [#24]
* BugFix: Lock Liquid Dependency to Version as above versions will break tests [#30]
* Feature: Turn DNT into a config option [#31]
* Refactor: Make Themes Import From App More Accepting [#35]

## 1.10.0.rc2 [#](https://github.com/enova/landable/compare/v1.10.0.rc1...v1.10.0.rc2)
* Feature: Set up configurable paths that are not visit tracked [#27]

## 1.10.0.rc1 [#](https://github.com/enova/landable/compare/v1.9.2...v1.10.0.rc1)
* BugFix: Handle blank UserAgent [#25]
* Refactor: Make table_name.rb generic. [#22]
* Refactor: Liquid Preview Template Styling [#21]

## 1.9.2 [#](https://github.com/enova/landable/compare/v1.9.1...v1.9.2)
* Feature: Added compatibility with new Rails 4.1 JSON-based cookies [#19]

## 1.9.1 [#](https://github.com/enova/landable/compare/v1.9.0...v1.9.1)
* Refactor: Updating lookup_by :event_type, and :country [#18]

## 1.9.0 [#](https://github.com/enova/landable/compare/v1.9.0.rc2...v1.9.0)
* Refacotr: Configuration is not a public API [#15]
* Refactor: Updating lookup_by :http_method [#16]
* Refactor: Updating descriptions of Partials [#17]

## 1.9.0.rc2 [#](https://github.com/enova/landable/compare/v1.9.0.rc1...v1.9.0.rc2)
* Feature: Audits [#10]

## 1.9.0.rc1 [#](https://github.com/enova/landable/compare/v1.8.0...v1.9.0.rc1)
* Refactor: Expose the tracker's referer domain & path [#14]
* Feature: adds a new view relating paths with response time, ordered by response time (longest first) [#13]
* BugFix: Remove the pgtap.sql file and dependency [#12]

## 1.8.0 [#](https://github.com/enova/landable/compare/v1.7.1.rc1...v1.8.0)
* Feature: Removing geminabox [#11]
* Refactor: Some fixes to the DB tests [#9]
* Feature: Rails 4.x support [#8]
* Feature: Screenshots by revision [#7]
* Feature: Soft deletes [#6]

## 1.7.1.rc1 [#](https://github.com/enova/landable/compare/v1.7.0...v1.7.1.rc1)
* Feature: Allow for revisions for Templates [#3]
