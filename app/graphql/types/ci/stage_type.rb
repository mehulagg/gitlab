# frozen_string_literal: true

module Types
  module Ci
    # rubocop: disable Graphql/AuthorizeTypes
    class StageType < BaseObject
      graphql_name 'CiStage'

      field :name, GraphQL::STRING_TYPE, null: true,
        description: 'Name of the stage'
      field :groups, Ci::GroupType.connection_type, null: true,
        extras: [:lookahead],
        description: 'Group of jobs for the stage'
      field :detailed_status, Types::Ci::DetailedStatusType, null: true,
            description: 'Detailed status of the stage'

      def detailed_status
        object.detailed_status(context[:current_user])
      end

      # Issues one query per pipeline
      def groups(lookahead:)
        needs_selected = %i[nodes jobs nodes]
          .reduce(lookahead) { |q, f| q.selection(f) }
          .selects?(:needs)
        key = [object.pipeline, object, needs_selected]

        BatchLoader::GraphQL.for(key).batch(default_value: []) do |keys, loader|
          by_pipeline = keys.group_by(&:first)
          include_needs = keys.any? { |k| k[2] }

          by_pipeline.each do |pl, key_group|
            project = pl.project
            stages = key_group.map(&:second).uniq
            indexed = stages.index_by(&:id)

            jobs_for_pipeline(pl, stages.map(&:id), include_needs).each do |stage_id, statuses|
              stage = indexed[stage_id]
              groups = ::Ci::Group.fabricate(project, stage, statuses)
              # we don't know (and do not care) whether this set of jobs was
              # loaded with needs preloaded as part of the key.
              [true, false].each { |b| loader.call([pl, stage, b], groups) }
            end
          end
        end
      end

      private

      # rubocop: disable CodeReuse/ActiveRecord
      def jobs_for_pipeline(pipeline, stage_ids, include_needs)
        results = pipeline.latest_statuses.where(stage_id: stage_ids)
        results = results.preload(:needs) if include_needs

        results.group_by(&:stage_id)
      end
      # rubocop: enable CodeReuse/ActiveRecord
    end
  end
end
