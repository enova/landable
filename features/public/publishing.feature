Feature: Only published revisions are publicly available

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
    Given a published page "/pubbed"
    When I choose another theme for the page
    And  I GET "/pubbed"
    Then the original theme should still be shown
    When I publish the page
    And  I GET "/pubbed"
    Then the new theme should now be shown

  Scenario: Changes to the theme itself do not need to be published (for now?)
    Given a published page "/pubbed"
    When I change the theme's body
    And  I GET "/pubbed"
    Then the new theme body should be shown

  Scenario: Unpublished status change
    Given a published page "/pubbed"
    When  I change the page to a 404
    And   I GET "/pubbed"
    Then  the response status should be 200
    When  I publish the page
    And   I GET "/pubbed"
    Then  the response status should be 404
    When  I revert to the previous revision
    And   I publish the page
    And   I GET "/pubbed"
    Then  the response status should be 200
