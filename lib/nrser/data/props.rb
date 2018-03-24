# Requirements
# =======================================================================

# Stdlib
# -----------------------------------------------------------------------

# Deps
# -----------------------------------------------------------------------

# Project / Package
# -----------------------------------------------------------------------
require 'nrser/refinements/types'

require_relative './prop'


# Refinements
# =======================================================================

using NRSER::Types


# Definitions
# =======================================================================

module NRSER::Data::Props
  DEFAULT_CLASS_KEY = '__class__';
  
  PROPS_VARIABLE_NAME = :@__NRSER_props
  INVARIANTS_VARIABLE_NAME = :@__NRSER_invariants
  PROP_VALUES_VARIABLE_NAME = :@__NRSER_prop_values
  
  
  # Module Methods (Utilities)
  # =====================================================================
  # 
  # These are *NOT* mixed in to including classes, and must be accessed
  # via `NRSER::Data::Props.<method_name>`.
  # 
  # They're utilities that should only really need to be used internally.
  # 
  
  
  # Get the **mutable reference** to the hash that holds
  # {NRSER::Data::Prop} instances (for this class only - inherited
  # props are added in `.props`).
  # 
  # @param [Class<NRSER::Data::Props>] klass
  #   Propertied class to get the ref for.
  # 
  # @return [Hash<Symbol, NRSER::Data::Prop>]
  #   Map of prop names to instances.
  # 
  def self.get_props_ref klass
    unless klass.instance_variable_defined? PROPS_VARIABLE_NAME
      klass.instance_variable_set PROPS_VARIABLE_NAME, {}
    end
    
    klass.instance_variable_get PROPS_VARIABLE_NAME
  end # .get_props_ref
  
  
  # Get the **mutable reference** to the set that holds additional types
  # invariants that instances must satisfy (for this class only - inherited
  # invariants are added in `.invariants`).
  # 
  # @param [Class<NRSER::Data::Props>] klass
  #   Propertied class to get the ref for.
  # 
  # @return [Set<NRSER::Types::Type>]
  #   Set of invariant types.
  # 
  def self.get_invariants_ref klass
    unless klass.instance_variable_defined? INVARIANTS_VARIABLE_NAME
      klass.instance_variable_set INVARIANTS_VARIABLE_NAME, Set.new
    end
    
    klass.instance_variable_get INVARIANTS_VARIABLE_NAME
  end # .get_invariants_ref
  
  
  # Instantiate a class from a data hash. The hash must contain the
  # `__class__` key and the target class must be loaded already.
  # 
  # **WARNING**
  # 
  # I'm sure this is all-sorts of unsafe. Please don't ever think this is
  # reasonable to use on untrusted data.
  # 
  # @param [Hash<String, Object>] data
  #   Data hash to load from.
  # 
  # @param
  # 
  # @return [NRSER::Data::Props]
  #   Instance of a propertied class.
  # 
  def self.UNSAFE_load_instance_from_data data, class_key: DEFAULT_CLASS_KEY
    t.hash_.check data
    
    unless data.key?( class_key )
      raise ArgumentError.new binding.erb <<-ERB
        Data is missing <%= class_key %> key - no idea what class to
        instantiate.
        
        Data:
        
            <%= data.pretty_inspect %>
        
      ERB
    end
    
    # Get the class name from the data hash using the key, checking that it's
    # a non-empty string.
    class_name = t.non_empty_str.check data[class_key]
    
    # Resolve the constant at that name.
    klass = class_name.to_const
    
    # Make sure it's one of ours
    unless klass.included_modules.include?( NRSER::Data::Props )
      raise ArgumentError.new binding.erb <<-ERB
        Can not load instance from data - bad class name.
        
        Extracted class name
        
            <%= class_name.inspect %>
        
        from class key
        
            <%= class_key.inspect %>
        
        which resolved to constant
        
            <%= klass.inspect %>
        
        but that class does not include the NRSER::Data::Props mixin, which we
        check for to help protect against executing an unrelated `.from_data`
        class method when attempting to load.
        
        Data:
        
            <%= data.pretty_inspect %>
        
      ERB
    end
    
    # Kick off the restore and return the result
    klass.from_data data
    
  end # .UNSAFE_load_instance_from_data
  
  
  # Hook to extend the including class with {NRSER::Data::Props:ClassMethods}
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
    #   Don't include properties that have a {NRSER::Data::Prop#source}.
    # 
    # @return [Hash{ Symbol => NRSER::Data::Prop }]
    #   Hash mapping property name to property instance.
    # 
    def props only_own: false, only_primary: false
      result = if !only_own && superclass.respond_to?(:props)
        superclass.props only_own: only_own, only_primary: only_primary
      else
        {}
      end
      
      own_props = NRSER::Data::Props.get_props_ref self
      
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
    #   Constructor options for {NRSER::Data::Prop}.
    # 
    # @return [NRSER::Data::Prop]
    #   The newly created prop, thought you probably don't need it (it's
    #   already all bound up on the class at this point), but why not?
    # 
    def prop name, **opts
      ref = NRSER::Data::Props.get_props_ref self
      
      t.sym.check name
      
      if ref.key? name
        raise ArgumentError.new <<-END.squish
          Prop #{ name.inspect } already set for #{ self }:
          #{ ref[name].inspect }
        END
      end
      
      prop = NRSER::Data::Prop.new self, name, **opts
      ref[name] = prop
      
      if prop.create_reader?
        class_eval do
          define_method prop.name do
            prop.get self
          end
        end
      end
      
      if prop.create_writer?
        class_eval do
          define_method "#{ prop.name }=" do |value|
            prop.set self, value
          end
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
      values = {}
      props = self.props
      
      data.each { |data_key, data_value|
        prop_key = case data_key
        when Symbol
          data_key
        when String
          data_key.to_sym
        end
        
        if  prop_key &&
            prop = props[prop_key]
          values[prop_key] = prop.value_from_data data_value
        end
      }
      
      self.new values
    end # #from_data
    
    
    def invariants only_own: false
      parent = if !only_own && superclass.respond_to?( :invariants )
        superclass.invariants only_own: false
      else
        Set.new
      end
      
      parent + NRSER::Data::Props.get_invariants_ref( self )
    end
    
    
    def invariant type
      NRSER::Data::Props.get_invariants_ref( self ).add type
    end
    
  end # module ClassMethods
  
  
  # Mixed-In Instance Methods
  # =====================================================================
  
  # Initialize the properties from a hash.
  # 
  # Called from `#initialize` in {NRSER::Data::Base}, but if you just
  # mix in {NRSER::Data::Props} you need to call it yourself.
  # 
  # @param [Hash<(String | Symbol) => Object>] values
  #   Property values. Keys will be normalized to symbols.
  # 
  # @return [nil]
  # 
  def initialize_props values
    self.class.props(only_primary: true).each { |name, prop|
      prop.set_from_values_hash self, values.to_options
    }
    
    # TODO  Now trigger all eager defaults (check prop getting trigger
    #       correctly)
    
    # Check additional type invariants
    self.class.invariants.each do |type|
      type.check self
    end
    
    nil
  end # #initialize_props
  
  
  def merge overrides = {}
    self.class.new(
      self.to_h(only_primary: true).merge(overrides.symbolize_keys)
    )
  end
  
  
  # Create a new hash with property names mapped to values.
  # 
  # @param [Boolean] only_own:
  #   When `true`, don't include parent properties.
  # 
  # @param [Boolean] only_primary:
  #   When `true`, don't include sourced properties.
  # 
  # @return [Hash<Symbol, Object>]
  #   Map of prop names to values.
  # 
  def to_h only_own: false, only_primary: false
    self.class.
      props(only_own: only_own, only_primary: only_primary).
      transform_values { |prop| prop.get self }
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
  # @param [Boolean] only_own:
  #   When `true`, don't include parent properties.
  # 
  # @param [Boolean] only_primary:
  #   When `true`, don't include sourced properties.
  # 
  # @param [Boolean] add_class:
  #   Add a special key with the class' name as the value.
  # 
  # @param [String] class_key:
  #   Name for special class key.
  # 
  # @return [Hash<String, Object>]
  #   Map of property names as strings to their "data" value, plus the special
  #   class identifier key and value, if requested.
  # 
  def to_data only_own: false,
              only_primary: false,
              add_class: true,
              class_key: NRSER::Data::Props::DEFAULT_CLASS_KEY
              
    self.class.props(only_own: false, only_primary: false).
      map { |name, prop|
        [name.to_s, prop.to_data(self)]
      }.
      to_h.
      tap { |hash|
        hash[class_key] = self.class.name if add_class
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