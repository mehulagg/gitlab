# frozen_string_literal: true

module Gitlab
  module Metrics
    module Samplers
      class GlobalSearchSampler < BaseSampler
        DEFAULT_SAMPLING_INTERVAL_SECONDS = 60

        def sample
          ::Elastic::MetricsUpdateService.new.execute
        end
      end
    end
  end
end
