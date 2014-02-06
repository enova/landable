Feature: Only published revisions are publicly available

  @allow-rescue
  Scenario: Never-published page
    Given a page "/unpub"
    When I GET "/unpub"
    Then the response status should be 404
    When I publish the page "/unpub"
    And  I GET "/unpub"
    Then the response status should be 200

  Scenario: Currently published revision
    Given a published page "/pubbed"
    When I GET "/pubbed"
    Then the response status should be 200
    And  the response body should include the body of page "/pubbed"

  Scenario: Unpublished change from one theme to another
    Given a published page "/pubbed" with a theme containing "foo"
    When I choose another theme containing "bar"
    And  I GET "/pubbed"
    Then I should see "foo"
    When I publish the page with another theme
    And  I GET "/pubbed"
    Then I should see "bar"

  Scenario: Changes to the theme itself do not need to be published (for now?)
    Given a published page "/pubbed" with a theme containing "foo"
    When I change the theme to contain "bar"
    And  I GET "/pubbed"
    Then I should see "bar"

  @allow-rescue
  Scenario: Unpublished status change
    Given a published page "/pubbed"
    When  I change the page to a 410
    And   I GET "/pubbed"
    Then  the response status should be 200
    When  I publish the page
    And   I GET "/pubbed"
    Then  the response status should be 404
    When  I revert to the previous revision
    And   I publish the page
    And   I GET "/pubbed"
    Then  the response status should be 200
