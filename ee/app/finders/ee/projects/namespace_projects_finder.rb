# frozen_string_literal: true

module EE
  # NamespaceProjectsFinder
  #
  # Extends NamespaceProjectsFinder
  #
  # Added arguments:
  #   params:
  #     has_vulnerabilities: boolean
  #     has_code_coverage: boolean
  #
  module Projects
    module NamespaceProjectsFinder
      extend ::Gitlab::Utils::Override

      private

      override :filter_projects
      def filter_projects(collection)
        collection = super(collection)
        collection = by_storage(collection)
        collection = by_vulnerabilities(collection)
        collection = by_code_coverage(collection)
        collection
      end

      def by_storage(items)
        if params[:sort].present? && params[:sort] == :storage
          items.order_by_total_repository_size_excess_desc(namespace.actual_size_limit)
        else
          items
        end
      end

      def by_vulnerabilities(items)
        params[:has_vulnerabilities].present? ? items.has_vulnerabilities : items
      end

      def by_code_coverage(items)
        params[:has_code_coverage].present? ? items.with_code_coverage : items
      end
    end
  end
end
