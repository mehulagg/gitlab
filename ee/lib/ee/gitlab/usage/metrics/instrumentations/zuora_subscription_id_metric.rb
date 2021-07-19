# frozen_string_literal: true

module Gitlab
  module Usage
    module Metrics
      module Instrumentations
        class ZuoraSubscriptionIdMetric < GenericMetric
          def value
            ::License.current.subscription_id
          end
        end
      end
    end
  end
end
