# frozen_string_literal: true

module Ci
  module StuckBuilds
    class DropScheduledWorker
      include ApplicationWorker

      sidekiq_options retry: 3

      feature_category :continuous_integration

      idempotent!

      def perform
        ::Ci::StuckBuilds::DropScheduledService.new.execute
      end
    end
  end
end
