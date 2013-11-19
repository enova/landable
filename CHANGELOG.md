# Changelog

See README.md before updating this file.

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
