# frozen_string_literal: true

module Analytics
  module DevopsAdoption
    class SegmentsFinder
      attr_reader :params, :current_user

      def initialize(current_user, params:)
        @current_user = current_user
        @params = params
      end

      def execute
        scope = ::Analytics::DevopsAdoption::Segment.ordered_by_name

        if direct_descendants_only?
          scope = scope.for_namespaces(parent_with_direct_descendants)
        else
          scope = scope.for_parent(parent_namespace) if parent_namespace
        end

        scope
      end

      private

      def parent_with_direct_descendants
        parent_namespace ? [parent_namespace] + parent_namespace.children : ::Group.top_most
      end

      def parent_namespace
        params[:parent_namespace]
      end

      def direct_descendants_only?
        params[:direct_descendants_only]
      end
    end
  end
end
