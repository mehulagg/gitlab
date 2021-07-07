# frozen_string_literal: true

module Ci
  module Minutes
    class UpdateMinutesByConsumptionWorker
      include ApplicationWorker

      sidekiq_options retry: 10
      feature_category :continuous_integration
      idempotent!

      def perform(consumption, project_id, namespace_id)
        project = Project.find_by_id(project_id)
        namespace = Namespace.find_by_id(namespace_id)

        ::Ci::Minutes::UpdateMinutesByConsumptionService.new(project, namespace).execute(consumption)
      end
    end
  end
end
