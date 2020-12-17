# frozen_string_literal: true

module Elastic
  module MigrationOptions
    extend ActiveSupport::Concern
    include Gitlab::ClassAttributes

    DEFAULT_THROTTLE_DELAY = 5.minutes

    def batched?
      self.class.get_batched
    end

    def throttle_delay
      self.class.get_throttle_delay
    end

    class_methods do
      def batched!
        class_attributes[:batched] = true
      end

      def get_batched
        class_attributes[:batched]
      end

      def throttle_delay(value)
        class_attributes[:throttle_delay] = value
      end

      def get_throttle_delay
        class_attributes[:throttle_delay] || DEFAULT_THROTTLE_DELAY
      end
    end
  end
end
