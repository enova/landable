# Changelog

See README.md before updating this file.

## Unreleased [#](https://git.cashnetusa.com/trogdor/landable/compare/v1.2.4...master)
* Ability to prevent users from creating pages with reserved paths
* Ability to add other non-Landable pages to the sitemap [#81]
* current_page returns correct page for previews and published pages [#79]
* URI.encode request.referer url [#80]
* Updated views for traffic [#84]
* Remove privilege grants [#85]

## v1.2.4 [#](https://git.cashnetusa.com/trogdor/landable/compare/v1.2.3...v1.2.4)
* Adding attribution_id to unique index on referers table [#74]
* Check for presence of user_agent before attempting to determine type [#77]
* Update to newrelic logging re: tracking [#75]
* Add host, protocol sitemap config options [#76]

## v1.2.3 [#](https://git.cashnetusa.com/trogdor/landable/compare/v1.2.2...v1.2.3)
* Can Exclude Pages from Sitemap via Category [#73]

## v1.2.2 [#](https://git.cashnetusa.com/trogdor/landable/compare/v1.2.1...v1.2.2)
* Return if meta_tags is not a Hash
* Print out string value if meta_tags is_a? String

## v1.2.1 [#](https://git.cashnetusa.com/trogdor/landable/compare/v1.2.0...v1.2.1)
* Handling Landable Published 404 Pages in the Route Constraint [#68, #69]

## v1.2.0 [#](https://git.cashnetusa.com/trogdor/landable/compare/v1.1.3...v1.2.0)
* Add error logging for NewRelic when @tracker.track or @tracker.save are rescued [#67]
* Liquid Body Tag can Handle Liquid Templates [#64]
* Add denormalized views over traffic tables. [#65]

## v1.1.2 [#](https://git.cashnetusa.com/trogdor/landable/compare/v1.1.2...v1.1.3)

* The traffic owners table needs a pk with a sequence [#62]

## v1.1.2 [#](https://git.cashnetusa.com/trogdor/landable/compare/v1.1.1...v1.1.2)

* Traffic owner and lookup_by fixes [#61]

## v1.1.1 [#](https://git.cashnetusa.com/trogdor/landable/compare/v1.1.0...v1.1.1)

* Upgrade lookup_by to 0.3.1 [#60]
* Index on landable.page_revisions(path, status_code) [#59]
* Remove "Minimal" theme [#58]
* README and CHANGELOG updates [#57]

## v1.1.0 [#](https://git.cashnetusa.com/trogdor/landable/compare/v1.0.6...v1.1.0)

* Visit tracking [#54]
* Fix for asset helpers in production [#53]
* Allow the parent app to handle routing errors [#49]
