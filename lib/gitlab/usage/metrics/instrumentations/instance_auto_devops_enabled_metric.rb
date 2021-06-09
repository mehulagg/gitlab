# frozen_string_literal: true

module Gitlab
  module Usage
    module Metrics
      module Instrumentations
        class InstanceAutoDevopsEnabledMetric < GenericMetric
          value do
            Gitlab::CurrentSettings.auto_devops_enabled?
          end
        end
      end
    end
  end
end
