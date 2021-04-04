require 'action_action'

#
# Example
#
#   class MyAction < ActiveAction::Base
#     after_perform :send_email, on: :success
#
#     def perform(email_address)
#
#     end
#
#     def send_email
#
#     end
#   end
#

module ActiveAction
  include ActionAction
end
