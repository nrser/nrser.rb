# encoding: UTF-8
# frozen_string_literal: true

# Requirements
# =======================================================================

# Stdlib
# -----------------------------------------------------------------------

# Deps
# -----------------------------------------------------------------------

# Project / Package
# -----------------------------------------------------------------------

# {Name} subclasses wrap name patterned classes
require 'nrser/meta/names'

# {Name} extends {Token}
require_relative './token'


# Refinements
# =======================================================================

require 'nrser/refinements/regexps'
using NRSER::Regexps


# Namespace
# =======================================================================

module  NRSER
module  Described
module  Cucumber
module  Tokens


# Definitions
# =======================================================================

  
class Name < Token

  def self.name_class name_class = nil
    unless name_class.nil?
      unquote_type name_class
      pattern send( "#{ quote }_quote", name_class )
    end
    
    unquote_type
  end
  
  def unquote
    self.class.unquote_type.new super()
  end
  
end # class Name
  

# /Namespace
# =======================================================================

end # module Tokens
end # module Cucumber
end # module Described
end # module NRSER
