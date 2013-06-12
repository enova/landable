Feature: Helpers are provided for Rails views that Landable didn't serve
  The dummy app defines a few routes before mounting
  Landable; we want to ensure those routes still function
  from both the application and Landable's perspective.

  Scenario: Application view references landable helpers
    Given a page "/priority" with title "Landable4Life"
    And   the robots meta tag of "/priority" is "noindex,nofollow"
    And   the body of page "/priority" is:
      """
      <h1>Inline HTML!</h1>
      """
    When  I GET "/priority"
    Then  the response status should be 200
    And   the element "title" should have inner text "Home: Landable4Life"
    And   the element "#path" should have inner text "/priority"
    And   the element "meta[name='robots'][content='noindex,nofollow']" should exist
