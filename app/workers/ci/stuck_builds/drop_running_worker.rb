# frozen_string_literal: true

module Ci
  module StuckBuilds
    class DropRunningWorker
      include ApplicationWorker

      sidekiq_options retry: 3

      feature_category :continuous_integration

      idempotent!

      def perform
        ::Ci::StuckBuilds::DropRunningService.new.execute
      end
    end
  end
end
