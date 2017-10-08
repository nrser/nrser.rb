require 'spec_helper'

require 'nrser/refinements'
using NRSER

require 'nrser/refinements/types'
using NRSER::Types


# NRSER::Types.array
# ========================================================================
# 
describe "NRSER::Types.array" do
  subject { NRSER::Types.method :array }
  
  it_behaves_like 'Type maker method',
    accepts: [
      [],
      [1, 2, 3],
      [:a, 2, 'c']
    ],
    
    rejects: [
      nil,
      {},
      '1,2,3',
    ],
    
    from_s: {
      accepts: {
        # String splitting with default splitter
        '1,2,3' => ['1', '2', '3'],
        '1, 2,   3' => ['1', '2', '3'],
        "1,\n2,\n3" => ['1', '2', '3'],
        
        # JSON encoded
        JSON.dump([1, 2, 3]) => [1, 2, 3],
        
        JSON.pretty_generate([
          {x: 'ex!'},
          {y: 'why?'}
        ]) => [{'x' => 'ex!'}, {'y' => 'why?'}],
      },
    },
    
    and_is_expected: {
      to: {
        have_attributes: {
          class: NRSER::Types::ArrayType,
          name: 'ArrayType',
        }
      }
    }
  
  it_behaves_like 'Type maker method',
    args: [t.int],
    
    accepts: [
      [],
      [1, 2, -3, 0],
    ],
    
    rejects: [
      [1, 2, :c],
    ],
    
    from_s: {
      accepts: {
        '1, 2, 3' => [1, 2, 3],
      },
      
      rejects: {
        'a, b, c' => ArgumentError,
      }
    }
  
end # NRSER::Types.array

# ************************************************************************

