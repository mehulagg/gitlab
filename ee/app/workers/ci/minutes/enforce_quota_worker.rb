# frozen_string_literal: true

module Ci
  module Minutes
    class EnforceQuotaWorker
      include ApplicationWorker
      include PipelineQueue

      urgency :low
      deduplicate :until_executed
      idempotent!

      # TODO: Add specs
      def perform(project_id)
        Project.find_by_id(project_id).try do |project|
          Ci::Minutes::EnforceQuotaService.new(project, nil).execute
        end
      end
    end
  end
end
