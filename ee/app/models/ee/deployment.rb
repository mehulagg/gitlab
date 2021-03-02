# frozen_string_literal: true

module EE
  # Project EE mixin
  #
  # This module is intended to encapsulate EE-specific model logic
  # and be prepended in the `Deployment` model
  module Deployment
    extend ActiveSupport::Concern

    prepended do
      include UsageStatistics

      state_machine :status do
        after_transition any => :success do |deployment|
          deployment.run_after_commit do
            ::Dora::RefreshDailyMetricsWorker
              .perform_in(10.seconds, # 5.minutes in production
                          deployment.environment_id,
                          Time.current.to_date.to_s)
          end
        end
      end
    end
  end
end
