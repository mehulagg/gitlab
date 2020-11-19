# frozen_string_literal: true

module Resolvers
  module Ci
    class CiChartResolver < BaseResolver
      type Types::Ci::CiChartType, null: true

      argument :project_id, ::Types::GlobalIDType[::Project],
        required: true,
        description: 'Project to get the chart data from'

      def resolve(project_id: nil)
        {
          total_pipeline_count: 100 # TODO: Use the actual model data
        }
      end

      private

      def project_param(project_id)
        return unless project_id

        { project: find_object(project_id) }
      end

      def find_object(gid)
        GlobalID::Locator.locate(gid)
      end
    end
  end
end
