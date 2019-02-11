# encoding: UTF-8
# frozen_string_literal: true



# Requirements
# ========================================================================

# Stdlib
# ------------------------------------------------------------------------

# Deps
# ------------------------------------------------------------------------

# Project / Package
# ------------------------------------------------------------------------

# Sub-tree
require_relative './example_group/describe'
require_relative './example_group/helpers'
require_relative './example_group/logger'
require_relative './example_group/overrides'

# Namespace
# =======================================================================

module  NRSER
module  Described
module  RSpec


# Definitions
# ========================================================================

# Extension methods that are mixed in to {RSpec::Core::ExampleGroup}.
# 
module ExampleGroup
  
  # Mix in the describe methods
  include Describe
  
  include Helpers
  
  include Logger


  def described_constructor_args
    metadata[ :constructor_args ]
  end

end # module ExampleGroup


# /Namespace
# ========================================================================

end # module RSpec
end # module  Described
end # module NRSER
