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

require 'nrser/rspex/described'


# Refinements
# =======================================================================


# Namespace
# =======================================================================


# Definitions
# =======================================================================

# @todo document DescribeMixins module.
# 
module DescribeMixins
  
  def Names; NRSER::Meta::Names;  end
  
  Described = NRSER::RSpex::Described
  
  
  def expect_it
    expect described.subject
  end
  
  
  def expect_described human_name
    expect described.find_by_human_name!( human_name ).subject
  end
    
  
  def described
    @described
  end
  
  
  def describe described
    @described = described
  end
  
  
  def describe_class class_name
    describe Described::Class.new \
      parent: described,
      subject: resolve_class( class_name )
  end
  
  
  def describe_method identifier
    Names.match identifier,
      Names::QualifiedSingletonMethod, ->( name ) {
        const = resolve_module name.module_name
        method = const.method name.method_name
        
        describe Described::Method.new \
          parent: described,
          subject: method
      },
      
      Names::QualifiedInstanceMethod, ->( name ) {
        cls = resolve_class name.module_name
        unbound_method = cls.instance_method name.method_name
        
        describe Described::InstanceMethod.new \
          parent: described,
          subject: unbound_method
      },
      
      Names::SingletonMethod, ->( name ) {
        describe Described::Method.new \
          parent: described,
          name: name.method_name
      },
      
      NRSER::Meta::Names::InstanceMethod, ->( name ) {
        describe Described::InstanceMethod.new \
          parent: described,
          name: name.method_name
      },
      
      NRSER::Meta::Names::Method, ->( name ) {
        describe Described::Method.new \
          parent: described,
          name: name
      }
  end
  
  
  def describe_param param_name, value
    if described.is_a? Described::Params
      described[ name ] = value
    else
      describe Described::Params.new \
        parent: described,
        values: { name => value }
    end
  end
  
end # module DescribeMixins

# /Namespace
# =======================================================================
