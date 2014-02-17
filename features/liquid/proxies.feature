Feature: Liquid proxies
  Proxies which help you to get needed association
  in more convenient way.

  Background:
    Given a page under test

  Scenario: category proxy
    Given a page with title "Title 1" and category "seo"
      And a page with title "Title 2" and category "seo"
      And the page's body is "{% body %}"
      And the page's body is "{% for page in categories.seo.pages %}{{page.title}}<br/>{% endfor %}"
    Then the rendered content should be:
      """
      Title 1<br/>Title 2<br/>
      """
