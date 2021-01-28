# frozen_string_literal: true

module Gitlab
  module Usage
    class Metric
      include ActiveModel::Model
      FALLBACK = -1

      InvalidMetricError = Class.new(RuntimeError)

      attr_accessor :definition

      validates :definition, presence: true

      def key_path
        definition.key_path
      end

      def instrument(value = nil, fallback: FALLBACK, &block)
        metric_value = if block_given?
                         instrument_block(fallback, &block)
                       else
                         value
                       end

        unflatten_key_path(metric_value)
      end

      def unflatten_key_path(value)
        unflatten(key_path.split('.'), value)
      end

      private

      def instrument_block(fallback, &block)
        yield
      rescue
        fallback
      end

      def unflatten(keys, value)
        loop do
          value = { keys.pop.to_sym => value }
          break if keys.blank?
        end
        value
      end
    end
  end
end
