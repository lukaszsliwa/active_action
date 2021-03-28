module ActiveAction
  class Base
    include ActiveSupport::Callbacks
    define_callbacks :perform

    extend ActiveAction::Callbacks
    include ActiveAction::Statuses

    attr_reader :status
    attr_accessor :value

    class << self
      alias_method :attributes, :attr_accessor

      def perform(*args)
        instance = self.new
        instance.value = instance.send(:perform_with_callbacks, *args)
        instance.success! if instance.status.nil?
        instance
      end

      def perform!(*args)
        if (instance = perform(*args)).error?
          raise ActiveAction::Error.new
        end
        instance
      end
    end

    def perform_with_callbacks(*args)
      run_callbacks :perform do
        perform(*args)
      end
    end
  end
end
