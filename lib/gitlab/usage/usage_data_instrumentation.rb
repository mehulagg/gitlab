# frozen_string_literal: true

module Gitlab
  module Usage
    class UsageDataInstrumentation
      class << self
        def data(force_refresh: false)
          usage_data = Gitlab::UsageData.data(force_refresh: force_refresh)
          usage_data.deep_merge!(Gitlab::UsageDataMetrics.uncached_data) if Feature.enabled?(:usage_data_instrumentation)
          usage_data
        end
      end
    end
  end
end
