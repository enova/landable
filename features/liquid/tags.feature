# This is totally a unit test, but it's much more informative to read
# this in cuke form.
Feature: Liquid Tags
  A number of custom liquid tags are made available to the page and theme bodies,
  enabling generation of HTML tags, referencing assets, etc.

  Background:
    Given the asset URI prefix is "https://landable.dev/_assets"
    And   a page under test
    And   these assets:
      | name    | description           |
      | panda   | Baz!                  |
      | cthulhu | Wisconsin Disclosures |
      | small   | Site Favicon          |


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

  Scenario: head_content
    Given the page's body is "{% head_content %}"
    And the page's head tag is "<head lang='en'><meta test='text'>"  
    Then the rendered content should be:
      """
      <head lang='en'><meta test='text'>
      """

  Scenario: img_tag
    Given the page's body is "{% img_tag panda %}"
    Then the rendered content should be:
      """
      <img alt="Baz!" src="https://landable.dev/_assets//uploads/panda.png" />
      """

  Scenario: asset_url and asset_description
    Given the page's body is:
      """
      <a href="{% asset_url cthulhu %}" title="{% asset_description cthulhu %}">Disclosures</a>
      """
    Then the rendered content should be:
      """
      <a href="https://landable.dev/_assets//uploads/cthulhu.jpg" title="Wisconsin Disclosures">Disclosures</a>
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

  Scenario: App asset tags
    Given the page's body is:
      """
      {% stylesheet_link_tag application %}
      {% javascript_include_tag application %}
      {% image_tag foo.jpg %}
      {% img_tag foo.jpg %}
      {% image_tag panda %}
      """
    Then  the rendered content should be:
      """
      <link href="/assets/application-496bc45b694565a2b9c97f3d515604b7.css" media="screen" rel="stylesheet" />
      <script src="/assets/application-cb18a7c1013ae9124eca2e2d00bae92a.js"></script>
      <img alt="Foo" src="/assets/foo-ac1cd7cf9811f9938e2b8937c60a24e6.jpg" />
      <img alt="Foo" src="/assets/foo-ac1cd7cf9811f9938e2b8937c60a24e6.jpg" />
      <img alt="Baz!" src="https://landable.dev/_assets//uploads/panda.png" />
      """
