Feature: Liquid drop for categories
  As a content author
  I want to be able to create category lists
  And I want to be able to create lists of pages

  Background:
    Given a page under test

  Scenario: Category list
    Given a "published" page with title "Title 1" and category "seo"
    Given a "published" page with title "Title 1" and category "affiliates"
    Given a "published" page with title "Title 1" and category "traditional"
    Given a "published" page with title "Title 1" and category "traditional"
    Given a "unpublished" page with title "Title 1" and category "traditional"
    When this page is rendered:
      """
        {% for category in categories %}{{ category.name }} ({{ category.pages.size }})
        {% endfor %}
      """
    Then the rendered content should be:
      """
        Uncategorized (0)
        Affiliates (1)
        PPC (0)
        SEO (1)
        Social (0)
        Email (0)
        Traditional (2)
      """

  Scenario: Category when there are no published pages
    Given a "unpublished" page with title "Title 1" and category "seo"
    When this page is rendered:
      """
        count: {{ categories.seo.pages.size }}
        {% for page in categories.seo.pages %}{{page.title}}{% endfor %}
      """
    Then the rendered content should be:
      """
        count: 0
      """

  Scenario: Category proxy when there is one published page
    Given a "published" page with title "Title 1" and category "seo"
    When this page is rendered:
      """
        count: {{ categories.seo.pages.size }}
        {% for page in categories.seo.pages %}{{page.title}}{% endfor %}
      """
    Then the rendered content should be:
      """
        count: 1
        Title 1
      """
