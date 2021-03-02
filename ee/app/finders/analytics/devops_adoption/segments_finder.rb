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
        ::Analytics::DevopsAdoption::Segment.where(namespace: namespaces_scope).ordered_by_name
      end

      private

      def namespaces_scope
        @namespaces_scope ||= begin
          if params[:direct_descendants_only]
            params[:parent_namespace] ? [params[:parent_namespace]] + params[:parent_namespace].children : ::Group.where(parent_id: nil)
          else
            params[:parent_namespace] ? params[:parent_namespace].self_and_descendants : ::Group.all
          end
        end
      end
    end
  end
end
