# frozen_string_literal: true

module EE
  module Search
    module ProjectService
      extend ::Gitlab::Utils::Override
      include ::Search::Elasticsearchable

      override :execute
      def execute
        return super unless use_elasticsearch? && default_branch?

        ::Gitlab::Elastic::ProjectSearchResults.new(
          current_user,
          params[:search],
          project: project,
          repository_ref: repository_ref,
          order_by: params[:order_by],
          sort: params[:sort],
          filters: { confidential: params[:confidential], state: params[:state] }
        )
      end

      def repository_ref
        params[:repository_ref]
      end

      def default_branch?
        return true if repository_ref.blank?

        project.root_ref?(repository_ref)
      end

      def elasticsearchable_scope
        project
      end
    end
  end
end
