# frozen_string_literal: true

module Analytics
  module DevopsAdoption
    class SnapshotsFinder
      attr_reader :params

      def initialize(params:)
        @params = params
      end

      def execute
        scope = Snapshot.by_end_time
        scope = by_namespace(scope)
        by_timespan(scope)
      end

      private

      def by_namespace(scope)
        scope.for_namespaces(params[:namespace_id])
      end

      def by_timespan(scope)
        scope.for_timespan(from: params[:end_time_after], to: params[:end_time_before])
      end
    end
  end
end
