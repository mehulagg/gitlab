# frozen_string_literal: true

module Gitlab
  module Usage
    module Metrics
      module Instrumentations
        class BaseMetric
          include Gitlab::Utils::UsageData

          attr_reader :time_frame
          attr_reader :extra

          def initialize(time_frame:, extra: {})
            @time_frame = time_frame
            @extra = extra
          end
        end
      end
    end
  end
end
