require 'active_support/dependencies/autoload'
require 'active_support/callbacks'

require 'active_action/version'
require 'active_action/statuses'
require 'active_action/callbacks'
require 'active_action/base'
require 'active_action/error'

#
# Examples
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
  extend ActiveSupport::Autoload

  autoload :Base
  autoload :Error
end
