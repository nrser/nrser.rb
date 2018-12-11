Feature: Describe a class
  
  Scenario: Class created from a source code block
    
    Given a class:
      """ruby
      class A
      end
      """
    
    Then the class is a {::Class}
    And it is a {::Module}
    And it has a `name` attribute that is a {::String}
  