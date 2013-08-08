# This is totally a unit test, but it's much more informative to read
# this in cuke form.
Feature: Liquid Tags
  A number of custom liquid tags are made available to the page and theme bodies,
  enabling generation of HTML tags, referencing assets, etc.

  Background:
    Given the asset URI prefix is "https://landable.dev/_assets"
    And   a page under test

  Scenario: title_tag
    Given the page's body is "{% title_tag %}"
    Then  the rendered content should be:
      """
      <title>Page Under Test</title>
      """

  Scenario: meta_tags
    Given the page's body is "{% meta_tags %}"
    And the page's meta tags are:
      | name     | content            |
      | robots   | noindex,nofollow   |
      | keywords | momoney,moproblems |
    Then the rendered content should be:
      """
      <meta content="noindex,nofollow" name="robots" />
      <meta content="momoney,moproblems" name="keywords" />
      """

  Scenario: Referencing a template
    Given the page's body is:
      """
      <div>{% template foo %}</div>
      """
    And   the template "foo" with body "<span>some stuff</span>"
    Then  the rendered content should be:
      """
      <div><span>some stuff</span></div>
      """

  Scenario: Referencing a template with variables
    Given the page's body is:
      """
      <div>{% template foo body: "seven" footer: "the end" %}</div>
      """
    And   the template "foo" with the body:
      """
      <span>{{ body | default: "eight" }}</span>
      <footer>{{ footer }}</footer>
      """
    Then  the rendered content should be:
      """
      <div><span>seven</span>
      <footer>the end</footer></div>
      """

  Scenario: Referencing a template with variable defaults
    Given the page's body is:
      """
      <div>{% template foo %}</div>
      """
    And   the template "foo" with the body:
      """
      <span>{{ body | default: "eight" }}</span>
      """
    Then  the rendered content should be:
      """
      <div><span>eight</span></div>
      """

  Scenario: Referencing a template that doesn't exist
    Given the page's body is:
      """
      <div>{% template foo %}</div>
      """
    Then  the rendered content should be:
      """
      <div><!-- render error: missing template "foo" --></div>
      """
