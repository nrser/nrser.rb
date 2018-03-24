# Refinements
# =======================================================================

using NRSER


# Definitions
# =======================================================================

class NRSER::Data::Props::Base
  include NRSER::Data::Props
  
  def initialize **values
    initialize_props values
  end
  
  # @todo Prob wanna improve this at some point, but it's better than nothing.
  # 
  # @return [String]
  #   a short string describing the instance.
  # 
  def to_s
    props_str = self.class.props( only_primary: true ).sort.map { |name, prop|
      "#{ name }=#{ prop.get( self ).inspect }"
    }.join ' '
    
    <<-END.squish
      #<#{ self.class.name } #{ props_str }>
    END
  end # #to_s
end # class NRSER::Data::Props::Base
