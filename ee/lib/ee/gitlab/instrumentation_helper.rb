# frozen_string_literal: true

module EE
  module Gitlab
    module InstrumentationHelper
      extend ::Gitlab::Utils::Override

      override :add_instrumentation_data
      def add_instrumentation_data(payload)
        super

        instrument_load_balancing(payload)
      end

      private

      def instrument_load_balancing(payload)
        load_balancing_payload = ::Gitlab::Metrics::Subscribers::LoadBalancing.load_balancing_payload

        payload.merge!(load_balancing_payload)
      end
    end
  end
end
