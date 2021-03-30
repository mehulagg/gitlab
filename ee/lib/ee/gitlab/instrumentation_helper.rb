# frozen_string_literal: true

module EE
  module Gitlab
    module InstrumentationHelper
      extend ::Gitlab::Utils::Override

      override :db_counter_payload
      def keys
        @keys ||= super + ::Gitlab::Metrics::Subscribers::ActiveRecord::DB_LOAD_BALANCING_COUNTERS
      end
    end
  end
end
