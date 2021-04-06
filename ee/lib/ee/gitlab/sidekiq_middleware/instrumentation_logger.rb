# frozen_string_literal: true

module EE
  module Gitlab
    module SidekiqMiddleware
      module InstrumentationLogger
        extend ::Gitlab::Utils::Override

        override :keys
        def keys
          super + [*::Gitlab::Metrics::Subscribers::ActiveRecord::DB_LOAD_BALANCING_COUNTERS,
                   *::Gitlab::Metrics::Subscribers::LoadBalancing::COUNTERS]
        end
      end
    end
  end
end
