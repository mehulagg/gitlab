# frozen_string_literal: true

module Gitlab
  module Usage
    module Metrics
      module Instrumentations
        class TimeStampMetric < GenericMetric
          def value
            Time.current
          end
        end
      end
    end
  end
end
