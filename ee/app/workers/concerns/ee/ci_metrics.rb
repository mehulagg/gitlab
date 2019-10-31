# frozen_string_literal: true

module EE
  module CiMetrics
    def default_labels(build)
      labels = super
      labels[:has_minutes] = !build.project.shared_runners_limit_namespace.shared_runners_minutes_used? ? "yes" : "no"

      labels
    end
  end
end
