# Landable Domain Model
An outline of useful nouns and verbs. Because I struggle to think without a solid vocabulary.

This does *not* represent a database schema, model names, or otherwise imply implementation details. It's just a way to [think through naming](http://martinfowler.com/bliki/TwoHardThings.html).

## Common

Nearly everything should likely have attributes such as:

1. `CreatedBy` / `CreatedAt`: who made it, when.
2. `History`: A set of {`ChangedBy`, `ChangedAt`, `Comment`, `WhatChanged`}
3. `WhatChanged`: nebulous placeholder concept that will vary by model.


## Core

1. **Layout**
   - `Name`: Ideally, needn't be unique; we might want '2-column with jumbotron' across multiple categories.
   - `Category`: Generally speaking, what type of page should this template be used for?
     1. Meta: About Us, Rates&Terms, ...
     2. Contract
     3. SEO / Affiliate / PPC
   - `Body`: DOM structure. Maybe more.
   - `Components`: What components are always included in this template?
   - `Dependents`: set of pages which use this template

2. **Path**: Because a `Page` is not necessarily what is displayed at `/payday-loans`
   - `Page`: if displaying a particular page
   - `Experiment`: if MVT

3. **Page**
   - `Name`
   - `Template`
   - `Body`: HTML content
   - `Paths`: what paths currently display this page?
   - `Experiments`: what experiments are currently testing this page?
   - `Components`: Additional components not included in template
   - `Visibility`: Whether this page is visible to the world, only campus IPs, no one at all, etc. Page visibility might be best represented as a state machine such as:
     1. _new_ -> { _public_, _private_, _invisible_ }
     2. _private_ -> { _public_, _invisible_ }
     3. etc.

4. **Component**: Standardized, templated content (HTML, CSS, JS, ...)
   - Think Bootstrap component.
   - `Name`: as always.
   - `Category`
     1. Meta tags
     2. Hero unit
     3. Tracking pixels
     4. Disclaimers
   - `Body`: HTML content
   - `Variables`: A component probably has a (hopefully small) set of values that will vary that should not require us to create a new component.
     1. Hero button text ("Apply Now!" on one page, "Apply" on another)
     2. Google Analytics tracking ID
   - `Dependents`: set of templates and pages currently use this component


## MVT

General idea:

- Landable is responsible for:
  1. Storing experiment definitions
  2. Tracking the performance of the experiments
- Publicist is responsible for the UX of:
  1. Editing experiment definitions (`Pages`, `EnableAt`, and similar metadata)
  2. View current performance data for an experiment

Nouns:

1. **Experiment**
   - Is an `Experiment` a test of the performance of N different `Pages`? Or a single `Page`, with the variants somehow encoded here?
   - `EnableAt` / `DisableAt`: auto-enable/disable
2. **Result**
