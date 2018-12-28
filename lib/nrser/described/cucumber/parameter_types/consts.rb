# encoding: UTF-8
# frozen_string_literal: true

# Requirements
# =======================================================================

# Project / Package
# -----------------------------------------------------------------------

# Using names of Ruby things
require 'nrser/meta/names'

# Using the parameter tokens
require 'nrser/described/cucumber/tokens'

# Need to extend in the {Quote} mixin
require 'nrser/described/cucumber/world/quote'

# Need to extend in the {Declare} mixin to get `.declare`, etc.
require_relative './declare'


# Refinements
# =======================================================================

require 'nrser/refinements/regexps'
using NRSER::Regexps


# Namespace
# =======================================================================

module  NRSER
module  Described
module  Cucumber
module  ParameterTypes


# Definitions
# =======================================================================

# Declarations of {Cucumber::Glue::DLS::ParameterType} construction values
# used to create parameter types that match constant names.
# 
module Consts
  
  extend Declare
  extend World::Quote
  
    
  def_parameter_type \
    name:           :const_name,
    patterns:       Tokens::Const,
    transformer:    :unquote
  
  
  def_parameter_type \
    name:           :const,
    patterns:       Tokens::Const,
    transformer:    :to_value
  
  
  def_parameter_type \
    name:           :module,
    patterns:       Tokens::Const,
    transformer:    :to_module
  

  def_parameter_type \
    name:           :class,
    patterns:       Tokens::Const,
    transformer:    :to_class
  
end # module Consts  


# /Namespace
# =======================================================================

end # module ParameterTypes
end # module Cucumber
end # module Described
end # module NRSER
