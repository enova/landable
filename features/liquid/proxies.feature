Feature: Liquid proxies
  Proxies which help you to get needed association
  in more convenient way.

  Background:
    Given a page under test

  Scenario: Category proxy when there is no published pages
    Given a "unpublished" page with title "Title 1" and category "seo"
    When this page is rendered:
      """
        {% for page in categories.seo.pages %}{{page.title}}{% endfor %}
      """
    Then the rendered content should be:
      """
        
      """

  Scenario: Category proxy when there is one published page
    Given a "published" page with title "Title 1" and category "seo"
    When this page is rendered:
      """
        {% for page in categories.seo.pages %}{{page.title}}{% endfor %}
      """
    Then the rendered content should be:
      """
        Title 1
      """
