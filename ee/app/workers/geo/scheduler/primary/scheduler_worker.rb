# frozen_string_literal: true

module Geo
  module Scheduler
    module Primary
      class SchedulerWorker < Geo::Scheduler::SchedulerWorker # rubocop:disable Scalability/IdempotentWorker
        tags :exclude_from_gitlab_com

        def perform
          return unless Gitlab::Geo.primary?

          super
        end
      end
    end
  end
end
