# frozen_string_literal: true

module Elastic
  class IndexProjectsByIdService
    def execute(project_ids: [], namespace_ids: [])
      projects = Project.find(project_ids)
      Elastic::ProcessInitialBookkeepingService.backfill_projects!(*projects)

      namespace_ids.each do |namespace_id|
        ElasticNamespaceIndexerWorker.perform_async(namespace_id, :index)
      end
    end
  end
end
