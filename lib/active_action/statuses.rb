module ActiveAction
  module Statuses
    {
      success: %i(success succeed done correct ready active),
      error: %i(error failure fail invalid incorrect inactive)
    }.each do |key, values|
      values.each do |value|
        define_method(:"#{value}?") { @status == key }

        define_method(:"#{value}!") { @status = key }
      end
    end
  end
end