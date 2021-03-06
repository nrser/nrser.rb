Feature: Decorate a method with multiple others
  
  Scenario: Decorate with two singleton methods
    Given a class:
      """ruby
      require 'nrser/decorate'
      
      class A
        extend NRSER::Decorate
        
        def self.decorator_1 receiver, target, *args, &block
          "A.decorator_1, #{ target.call *args, &block }"
        end
        
        def self.decorator_2 receiver, target, *args, &block
          "A.decorator_2, #{ target.call *args, &block }"
        end
        
        decorate  :'.decorator_1',
                  :'.decorator_2',
        # The target instance method.
        # 
        # @return [Stirng]
        # 
        def f
          "A#f."
        end
        
      end
      """
    
    When I create a new instance of {A} with no parameters
    And I call `f` with no parameters
    
    Then the response is equal to "A.decorator_1, A.decorator_2, A#f."
