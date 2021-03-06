# encoding: UTF-8
# frozen_string_literal: true


# Namespace
# =======================================================================

module  NRSER
module  RSpex
module  ExampleGroup
module  Describe


# Definitions
# ========================================================================

# For use when `subject` is a {NRSER::Message}. Create a new context for
# the `receiver` where the subject is the result of sending that message
# to the receiver.
# 
# @param [Object] receiver
#   Object that will receive the message to create the new subject.
#   
#   If it's a {Wrapper} it will be unwrapped in example contexts of the
#   new example group.
# 
# @param [Boolean] publicly
#   Send message publicly via {Object#public_send} (default) or privately
#   via {Object.send}.
# 
# @param bind_subject:  (see #describe_x)
# @param &body          (see #describe_x)
# 
# @return (see #describe_x)
# 
def describe_sent_to  receiver,
                      publicly: true,
                      bind_subject: true,
                      &body
  mode = if publicly
    "publicly"
  else
    "privately"
  end
  
  describe_x \
    receiver,
    "(#{ mode })",
    type: :sent_to,
    metadata: {
      receiver: receiver,
    },
    bind_subject: bind_subject,
    subject_block: -> {
      super().send_to \
        unwrap( receiver, context: self ),
        publicly: publicly
    },
    &body
end # #describe_sent_to

# Aliases to other names I was using at first... not preferring their use
# at the moment.
alias_method :sent_to, :describe_sent_to


# /Namespace
# ========================================================================

end # module Describe
end # module ExampleGroup
end # module RSpex
end # module NRSER
