Feature: Loginpage
  As a user
  I want to visit the login page
  So I can log into the application

  Scenario: Entering valid credentials into login page takes us to dashboard
    Given I am on the login page
    And I enter valid credentials into the input fields
    When I click the login button
    Then I should be redirected to dashboard
