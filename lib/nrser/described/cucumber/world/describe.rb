# encoding: UTF-8
# frozen_string_literal: true

# Requirements
# =======================================================================

# Stdlib
# -----------------------------------------------------------------------

# Deps
# -----------------------------------------------------------------------

# Using {::String#camelize}
require 'active_support/core_ext/string/inflections'

# Project / Package
# -----------------------------------------------------------------------

require 'nrser/described'


# Refinements
# =======================================================================

require 'nrser/refinements/types'
using NRSER::Types


# Namespace
# =======================================================================

module  NRSER
module  Described
module  Cucumber
module  World


# Definitions
# =======================================================================

# World mixins to manage the description hierarchy.
# 
# Mixed in to the "step classes" where steps are executed via 
# {Cucumber::Glue::DSL::World}.
# 
module Describe
  
  # Instance Methods
  # ========================================================================
  
  # Shortcut to {NRSER::Meta::Names}.
  # 
  # @return [::Module]
  # 
  def Names; NRSER::Meta::Names;  end
  
  
  # @!group Accessing Descriptions Instance Methods
  # --------------------------------------------------------------------------
  
  # What's being described.
  # 
  # @return [nil]
  #   When nothing has been {#describe}'d yet.
  # 
  # @return [NRSER::Described::Base]
  #   The current description instance (youngest child in the description
  #   hierarchy).
  #   
  def described
    @described
  end
  
  
  # Set {#described} to a new {NRSER::Described::Base} instance whose
  # parent is the current {#described}.
  # 
  # @overload describe described
  #   Describe an already constructed {NRSER::Described::Base}.
  #   
  #   @note
  #     I think this is kind-of legacy at this point, preferring the second
  #     form that avoids having to properly provide the `parent` at every
  #     construction site.
  #   
  #   @param [NRSER::Described::Base] described
  #     The new description.
  #     
  #     Check that the {NRSER::Described::Base#parent} is the current
  #     {#described}.
  #   
  #   @return [NRSER::Described::Base]
  #     Newly set {#described}.
  # 
  # @overload describe described_name, **kwds
  #   Construct a new described using the name of the class and keyword 
  #   parameters.
  #   
  #   @note
  #     I think this is the preferred form of the method, as it will let me 
  #     thin out some of the `#describe_...` methods that don't do anything
  #     more than this.
  #     
  #   @example
  #     describe :object, subject: "whatever"
  #   
  #   @param [::String | ::Symbol] described_name
  #     Which class to construct.
  #   
  #   @param [Hash<Symbol, Object>] kwds
  #     Keyword parameters to pass to the described class' constructor.
  #     
  #     Don't put `parent:` in here; it's added automatically.
  #     
  #   @return [NRSER::Described::Base]
  #     Newly set {#described}.
  #     
  def describe *args
    @described = t.match args,
      t.tuple( NRSER::Described::Base ),
        ->( (described) ) {
          unless described.parent.equal? @described
            raise NRSER::ArgumentError.new \
              "A constructed", NRSER::Described::Base, "was passed as the sole",
              "argument, but it's parent is not the current {#described}",
              new_described: described,
              current_described: @described
          end
          
          described
        },
      
      ( t.tuple( t.Label ) | t.tuple( t.Label, t.Kwds ) ),
        ->( (described_name, kwds) ) {
          NRSER::Described.
            const_get( described_name.to_s.camelize ).
            new \
              **( kwds || {} ),
              parent: @described
        }
  end # #describe
  
  # @!endgroup Accessing Descriptions Instance Methods # *********************
  
  def value_for string, accept_unary_ampersand: false
    if expr? string
      source_string = backtick_unquote string
      
      if accept_unary_ampersand && unary_ampersand_expr?( source_string )
        eval "->( &block ) { block }.call( #{ source_string } )"
      else
        eval source_string
      end
    else
      raise NRSER::NotImplementedError.new \
        "TODO can only handle expr strings so far, found", string.inspect,
        "(which is a", string.class, ")"
    end
  end
  
  
  # @!group Describe Helper Instance Methods
  # --------------------------------------------------------------------------
  
  def describe_class class_name
    describe :class, subject: resolve_class( class_name )
  end
  
  
  def describe_module module_name
    describe :module, subject: resolve_module( module_name )
  end
  
  
  def describe_method identifier
    Names.match identifier,
      Names::QualifiedSingletonMethod, ->( name ) {
        const = resolve_module name.module_name
        method = const.method name.method_name
        
        describe :method, subject: method
      },
      
      Names::QualifiedInstanceMethod, ->( name ) {
        cls = resolve_class name.module_name
        unbound_method = cls.instance_method name.method_name
        
        describe :instance_method, subject: unbound_method
      },
      
      Names::SingletonMethod, ->( name ) {
        describe :method, name: name.method_name
      },
      
      NRSER::Meta::Names::InstanceMethod, ->( name ) {
        describe :instance_method, name: name.method_name
      },
      
      NRSER::Meta::Names::Method, ->( name ) {
        describe :method, name: name
      }
  end
  
  
  def describe_param name, value
    if described.is_a? NRSER::Described::Parameters
      described[ name ] = value
    else
      describe :parameters,
        subject: NRSER::Meta::Params.new( named: { name => value } )
    end
  end
  
  
  def describe_positional_params strings
    # Unquote to {SourceString} instances, if not already
    source_strings = strings.map { |s| backtick_unquote s }
    
    # Handle the last entry being a `&...` expression, which is interpreted as 
    # the block parameter
    if unary_ampersand_expr? source_strings[ -1 ]
      args = source_strings[ 0..-2 ].map { |s| value_for s }
      block = value_for source_strings[ -1 ], accept_unary_ampersand: true
    else
      args = source_strings.map { |s| value_for s }
      block = nil
    end
    
    describe :parameters,
      subject: NRSER::Meta::Params.new( args: args, block: block )
  end
  
  # @!endgroup Describe Helper Instance Methods # ****************************
  
end # module DescribeMixins


# /Namespace
# =======================================================================

end # module World
end # module Cucumber
end # module Described
end # module NRSER
