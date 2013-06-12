Feature: Liquid templating support in themes
  Background:
    Given a published page "/hullo" titled "Hi!" with theme "liquid"
  
  Scenario: landable.title
    Given the body of theme "liquid" is "{{ landable.title }}"
    When I GET "/hullo"
    Then the response status should be 200
    And  the response body should be "<title>Hi!</title>"
    
  Scenario: landable.meta_tags

  Scenario: landable.head

  Scenario: landable.body

