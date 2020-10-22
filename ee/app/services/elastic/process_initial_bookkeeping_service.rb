# frozen_string_literal: true

module Elastic
  class ProcessInitialBookkeepingService < Elastic::ProcessBookkeepingService
    REDIS_SET_KEY = 'elastic:bulk:initial:0:zset'
    REDIS_SCORE_KEY = 'elastic:bulk:initial:0:score'

    INDEXED_ASSOCIATIONS = [
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

          maintain_indexed_associations(project)

          ElasticCommitIndexerWorker.perform_async(project.id)
          ElasticCommitIndexerWorker.perform_async(project.id, nil, nil, true)
        end
      end

      def each_indexed_association(project)
        INDEXED_ASSOCIATIONS.each do |association_name|
          association = project.association(association_name)
          scope = association.scope
          klass = association.klass

          if klass == Note
            scope = scope.searchable
          end

          yield klass, scope
        end
      end

      private

      def maintain_indexed_associations(project)
        each_indexed_association(project) do |_, association|
          association.find_in_batches do |group|
            track!(*group)
          end
        end
      end
    end
  end
end
