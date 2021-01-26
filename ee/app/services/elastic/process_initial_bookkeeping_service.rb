# frozen_string_literal: true

module Elastic
  class ProcessInitialBookkeepingService < Elastic::ProcessBookkeepingService
    REDIS_SET_KEY = 'elastic:bulk:initial:0:zset'
    REDIS_SCORE_KEY = 'elastic:bulk:initial:0:score'
    INDEXED_PROJECT_ASSOCIATIONS = [
      :issues,
      :merge_requests,
      :snippets,
      :notes,
      :milestones
    ].freeze

    class << self
      def backfill_projects!(*projects)
        track!(*projects)

        projects.each do |project|
          raise ArgumentError, 'This method only accepts Projects' unless project.is_a?(Project)

          maintain_indexed_associations(project, INDEXED_PROJECT_ASSOCIATIONS)

          ElasticCommitIndexerWorker.perform_async(project.id)
          ElasticCommitIndexerWorker.perform_async(project.id, nil, nil, true)
        end
      end
    end
  end
end
