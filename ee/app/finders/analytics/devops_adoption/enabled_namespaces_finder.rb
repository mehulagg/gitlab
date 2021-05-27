# frozen_string_literal: true

module Analytics
  module DevopsAdoption
    class EnabledNamespacesFinder
      attr_reader :params, :current_user

      def initialize(current_user, params:)
        @current_user = current_user
        @params = params
      end

      def execute
        scope = ::Analytics::DevopsAdoption::EnabledNamespace.ordered_by_name
        by_display_namespace(scope)
      end

      private

      def by_display_namespace(scope)
        scope.for_display_namespaces(params[:display_namespace])
      end
    end
  end
end
