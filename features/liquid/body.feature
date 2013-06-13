Feature: Page body via `body` variable
  Scenario: Theme accesses rendered page body via `body` variable
    Given a theme with the body:
      """
      <div class="container">{{body}}</div>
      """
    When this page is rendered:
      """
      <h1>Hi mom!</h1>
      """
    Then the rendered content should be:
      """
      <div class="container"><h1>Hi mom!</h1></div>
      """

  Scenario: Rendering a page that attempts to inject Liquid markup into its theme
    Given a theme with the body "{{body}}"
    When  this page is rendered:
      """
      {% raw %}{{body}}{% endraw %}
      """
    Then the rendered content should be:
      """
      {{body}}
      """

  Scenario: Page rendering does not provide a `body` variable
    When this page is rendered:
      """
      <div>{{body}}</div>
      """
    Then the rendered content should be:
      """
      <div></div>
      """
