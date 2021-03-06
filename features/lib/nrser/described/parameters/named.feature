Feature: Describe parameters by name
  
  Scenario: Describing named positional and keyword parameters in steps
    
    Positional and keyword parameters may each be described by name in separate
    "given" steps.
    
    Given a module:
      """ruby
      module M
        def self.f a_0, a_1, k_0:, k_1:
          { a_0: a_0, a_1: a_1, k_0: k_0, k_1: k_1 }
        end
      end
      """
    
    And the module's method {.f}
    
    # NOTE  These steps could be given in any order
    And the `a_0` parameter is `1`
    And the `a_1` parameter is `2`
    And the `k_0:` parameter is "three"
    And the `k_1:` parameter is "four"
    
    When I call the method with the parameters
    
    Then the response is equal to:
      """ruby
      { a_0: 1, a_1: 2, k_0: "three", k_1: "four" }
      """
  
  
  Scenario: Describing named positional and keyword parameters in a table
    
    Positional and keyword parameters may also be described by name/value rows
    in a two-column table.
    
    Given a module:
      """ruby
      module M
        def self.f a_0, a_1, k_0:, k_1:
          { a_0: a_0, a_1: a_1, k_0: k_0, k_1: k_1 }
        end
      end
      """
    
    And the module's method {.f}
    
    # NOTE  The table headings must be present, but their values don't matter.
    And the parameters:
      | NAME  | VALUE   |
      | a_0   | `1`     |
      | a_1   | `2`     |
      | k_0:  | "three" |
      | k_1:  | "four"  |
    
    When I call the method with the parameters
    
    Then the response is equal to:
      """ruby
      { a_0: 1, a_1: 2, k_0: "three", k_1: "four" }
      """


  Scenario: Describing "rest" (splat / variable-length) parameters
    
    Given a module:
      """ruby
      module M
        def self.f x, y, *rest, z:
          { x: x, y: y, rest: rest, z: z }
        end
      end
      """
    
    And the module's method {.f}
    
    # NOTE  The table headings must be present, but their values don't matter.
    And the parameters:
      | NAME    | VALUE                 |
      | x       | `1`                   |
      | y       | `2`                   |
      | *rest   | `[ "three", "four" ]` |
      | z:      | "five"                |
    
    When I call the method with the parameters
    
    Then the response is equal to:
      """ruby
      { x: 1, y: 2, rest: [ "three", "four" ], z: "five" }
      """
  

  Scenario: Describing "key-rest" (double-splat / keyword hash) parameters
    
    Given a module:
      """ruby
      module M
        def self.f x, y:, **keyrest
          { x: x, y: y, keyrest: keyrest }
        end
      end
      """
    
    And the module's method {.f}
    
    # NOTE  The table headings must be present, but their values don't matter.
    And the parameters:
      | NAME      | VALUE                 |
      | x         | `1`                   |
      | y:        | `2`                   |
      | **keyrest | `{ z: 3, w: 4}`       |
    
    When I call the method with the parameters
    
    Then the response is equal to:
      """ruby
      { x: 1, y: 2, keyrest: { z: 3, w: 4 } }
      """