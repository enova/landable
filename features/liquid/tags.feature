# This is totally a unit test, but it's much more informative to read
# this in cuke form.
Feature: Liquid Tags
  A number of custom liquid tags are made available to the page and theme bodies,
  enabling generation of HTML tags, referencing assets, etc.

  Background:
    Given the asset URI prefix is "https://landable.dev/_assets/"
    And   a page under test
    And   the page has these assets:
      | basename | name    | description           | alias |
      | foo.png  | bar     | Baz!                  |       |
      | wi.pdf   | doc     | Wisconsin Disclosures |       |
      | fav.ico  | favicon | Site Favicon          | icon  |

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

  Scenario: img_tag
    Given the page's body is "{% img_tag bar %}"
    Then the rendered content should be:
      """
      <img alt="Baz!" src="https://landable.dev/_assets/foo.png" />
      """

  Scenario: asset_url and asset_description
    Given the page's body is:
      """
      <a href="{% asset_url doc %}" title="{% asset_description doc %}">Disclosures</a>
      """
    Then the rendered content should be:
      """
      <a href="https://landable.dev/_assets/wi.pdf" title="Wisconsin Disclosures">Disclosures</a>
      """

  Scenario: Referencing your theme's asset
    Given the page's body is:
      """
      {% asset_url theme/header %}
      """
    And the page uses a theme with the body:
      """
      {% asset_url header %}
      {{body}}
      """
    And the theme has these assets:
      | basename | name   | description  |
      | hdr.png  | header | Header image |
    Then the rendered content should be:
      """
      https://landable.dev/_assets/hdr.png
      https://landable.dev/_assets/hdr.png
      """

  Scenario: Reference the asset alias
    Given the page's body is "{% img_tag icon %}"
    Then  the rendered content should be:
      """
      <img alt="Site Favicon" src="https://landable.dev/_assets/fav.ico" />
      """
