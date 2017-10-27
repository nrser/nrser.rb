# Definitions
# =======================================================================

module NRSER
  
  # Converts all keys into strings by calling `#to_s` on them. **Mutates the
  # hash.**
  # 
  # Lifted from ActiveSupport.
  # 
  # @param [Hash] hash
  # 
  # @return [Hash<String, *>]
  # 
  def self.stringify_keys! hash
    transform_keys! hash, &:to_s
  end
  
  singleton_class.send :alias_method, :str_keys!, :stringify_keys!
  
  
  # Returns a new hash with all keys transformed to strings by calling `#to_s`
  # on them.
  # 
  # Lifted from ActiveSupport.
  # 
  # @param [Hash] hash
  # 
  # @return [Hash<String, *>]
  # 
  def self.stringify_keys hash
    transform_keys hash, &:to_s
  end
  
  singleton_class.send :alias_method, :str_keys, :stringify_keys

end # module NRSER