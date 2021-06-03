# frozen_string_literal: true

module Analytics
  module DevopsAdoption
    class SnapshotsFinder
      attr_reader :params, :current_user, :enabled_namespace

      def initialize(current_user, enabled_namespace, params:)
        @current_user = current_user
        @enabled_namespace = enabled_namespace
        @params = params
      end

      def execute
        scope = enabled_namespace.snapshots.by_end_time
        by_timespan(scope)
      end

      private

      def by_timespan(scope)
        scope.for_timespan(before: params[:end_time_before], after: params[:end_time_after])
      end
    end
  end
end
