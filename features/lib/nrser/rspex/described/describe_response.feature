Feature: Describe a method's response
  
  These scenarios walk through examples of how to describe the response to a
  method call, which is represented internally by a
  {NRSER::RSpex::Described::Response} instance.
  
  Scenario: (1)  Describing the response of a class' singleton method 
    
    Given the class {::NRSER::RSpex::Described::Base}
    And the class' method `default_human_name`
    
    When I call the method with no parameters
    
    Then the response is equal to "base"
  
  
  Scenario: (2)  Using implicit ("it(s)") language
    
    This is functionally the same as scenario (1), but uses "it(s)" to build the
    description hierarchy instead of explicitly stating what it's referring to.
    
    I generally find this a lot more confusing an vague, and discourage its
    use, but since its available it is documented.
    
    Given the class {::NRSER::RSpex::Described::Base}
    And its method `default_human_name`
    
    When I call it with no parameters
    
    Then it is equal to "base"
  
  
  Scenario: (3)  Using short-hand to directly identify a singleton method
    
    The method can be identified directly without first describing the module
    it belongs to in a separate step.
    
    Given the method {::NRSER::RSpex::Described::Base.default_human_name}
    
    When I call it with no parameters
    
    Then it is equal to "base"