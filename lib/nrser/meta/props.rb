require 'pp'

require 'nrser/refinements'
require 'nrser/refinements/types'

using NRSER
using NRSER::Types

module NRSER 
module Meta

module Props
  CLASS_KEY = '__class__';
  PROPS_VARIABLE_NAME = :@__NRSER_props
  PROP_VALUES_VARIABLE_NAME = :@__NRSER_prop_values
  
  
  # Module Methods (Utilities)
  # =====================================================================
  # 
  # These are *NOT* mixed in to including classes, and must be accessed 
  # via `NRSER::Meta::Props.<method_name>`.
  # 
  # They're utilities that should only really need to be used internally.
  # 
  
  
  # @todo Document get_props_ref method.
  # 
  # @param [type] arg_name
  #   @todo Add name param description.
  # 
  # @return [return_type]
  #   @todo Document return value.
  # 
  def self.get_props_ref klass
    unless klass.instance_variable_defined? PROPS_VARIABLE_NAME
      klass.instance_variable_set PROPS_VARIABLE_NAME, {}
    end
    
    klass.instance_variable_get PROPS_VARIABLE_NAME
  end # .get_props_ref
  
  
  # Instantiate a class from a data hash. The hash must contain the
  # `__class__` key and the target class must be loaded already.
  # 
  # **WARNING**
  # 
  # I'm sure this is all-sorts of unsafe. Please don't ever think this is 
  # reasonable to use on untrusted data.
  # 
  # @param [Hash<String, Object>] data
  # 
  # @return [Object]
  #   @todo Document return value.
  # 
  # 
  # 
  def self.from_data data
    t.hash_.check data
    
    unless data.key?(CLASS_KEY)
      raise ArgumentError.new <<-END.dedent
        Data is missing #{ CLASS_KEY } key - no idea what class to instantiate.
        
        #{ data.pretty_inspect }
      END
    end
    
    class_name = t.str.check data[CLASS_KEY]
    klass = class_name.to_const
    klass.from_data data
  end # .from_data
  
  
  # Hook to extend the including class with {NRSER::Meta::Props:ClassMethods}
  def self.included base
    base.extend ClassMethods
  end
  
  
  # Mixed-In Class Methods
  # ===================================================================== 
  
  # Methods added to the including *class* via `extend`.
  # 
  module ClassMethods
    
    # Get a map of property names to property instances.
    # 
    # @param [Boolean] only_own:
    #   Don't include super-class properties.
    # 
    # @param [Boolean] only_primary:
    #   Don't include properties that have a {NRSER::Meta::Props::Prop#source}.
    # 
    # @return [Hash{ Symbol => NRSER::Meta::Props::Prop }]
    #   Hash mapping property name to property instance.
    # 
    def props only_own: false, only_primary: false
      result = if !only_own && superclass.respond_to?(:props)
        superclass.props only_own: only_own, only_primary: only_primary
      else
        {}
      end
      
      own_props = NRSER::Meta::Props.get_props_ref self
      
      if only_primary
        own_props.each {|name, prop|
          if prop.primary?
            result[name] = prop
          end
        }
      else
        result.merge! own_props
      end
      
      result
    end # #own_props
    
    
    # Define a property.
    # 
    # @param [Symbol] name
    #   The name of the property.
    # 
    # @param [Hash{ Symbol => Object }] **opts
    #   Constructor options for {NRSER::Meta::Props::Prop}.
    # 
    # @return [NRSER::Meta::Props::Prop]
    #   The newly created prop, thought you probably don't need it (it's 
    #   already all bound up on the class at this point), but why not?
    # 
    def prop name, **opts
      ref = NRSER::Meta::Props.get_props_ref self
      
      t.sym.check name
      
      if ref.key? name
        raise ArgumentError.new NRSER.squish <<-END
          Prop #{ name.inspect } already set for #{ self }:
          #{ ref[name].inspect }
        END
      end
      
      prop = Prop.new self, name, **opts
      ref[name] = prop
      
      unless prop.source?
        class_eval do
          define_method(name) do
            prop.get self
          end
          
          # protected
          #   define_method("#{ name }=") do |value|
          #     prop.set self, value
          #   end
        end
      end
      
      prop
    end # #prop
    
    
    # Instantiate from a data hash.
    # 
    # @todo
    #   This needs to be extended to handle prop'd classes nested in
    #   arrays and hashes... but for the moment, it is what it is.
    # 
    # @param [Hash<String, Object>] data
    # 
    # @return [self]
    # 
    def from_data data
      self.new data.symbolize_keys
    end # #from_data
    
    
  end # module ClassMethods
  
  
  # Mixed-In Instance Methods
  # =====================================================================
  
  # @todo Document initialize_props method.
  # 
  # @param [type] arg_name
  #   @todo Add name param description.
  # 
  # @return [return_type]
  #   @todo Document return value.
  # 
  def initialize_props values
    self.class.props(only_primary: true).each { |name, prop|
      prop.set_from_values_hash self, values
    }
  end # #initialize_props
  
  
  def merge overrides = {}
    self.class.new(
      self.to_h(only_primary: true).merge(overrides.symbolize_keys)
    )
  end
  
  
  # @todo Document to_h method.
  # 
  # @param [type] arg_name
  #   @todo Add name param description.
  # 
  # @return [Hash<Symbol, Object>]
  #   @todo Document return value.
  # 
  def to_h only_own: false, only_primary: false
    self.class.
      props(only_own: only_own, only_primary: only_primary).
      map_values { |name, prop| prop.get self }
  end # #to_h
  
  
  # Create a "data" representation suitable for transport, storage, etc.
  # 
  # The result is meant to consist of only basic data types and structures -
  # strings, numbers, arrays, hashes, datetimes, etc... though it depends on 
  # any custom objects it encounters correctly responding to `#to_data` for 
  # this to happen (as is implemented from classes that mix in Props here).
  # 
  # Prop names are converted to strings (from symbols) since though YAML
  # supports symbol values, they have poor portability across languages,
  # and they mean the same thing in this situation. 
  # 
  # @param [type] arg_name
  #   @todo Add name param description.
  # 
  # @return [Hash<String, Object>]
  #   @todo Document return value.
  # 
  def to_data only_own: false, only_primary: false, add_class: true
    self.class.props(only_own: false, only_primary: false).
      map { |name, prop|
        [name.to_s, prop.to_data(self)]
      }.
      to_h.
      tap { |hash|
        hash[CLASS_KEY] = self.class.name if add_class
      }
  end # #to_data
  
  
  # Language Inter-Op
  # ---------------------------------------------------------------------
  
  # Get a JSON {String} encoding the instance's data.
  # 
  # @param [Array] *args
  #   I really don't know. `#to_json` takes at last one argument, but I've
  #   had trouble finding a spec for it :/
  # 
  # @return [String]
  # 
  def to_json *args
    to_data.to_json *args
  end # #to_json
  
  
  # Get a YAML {String} encoding the instance's data.
  # 
  # @param [Array] *args
  #   I really don't know... whatever {YAML.dump} sends to it i guess.
  # 
  # @return [String]
  #   
  def to_yaml *args
    to_data.to_yaml *args
  end
  
  
end # module Props

end # module Meta
end # module NRSER

require_relative './props/prop'
require_relative './props/base'