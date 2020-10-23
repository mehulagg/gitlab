# frozen_string_literal: true

module EE
  module Search
    module SnippetService
      extend ::Gitlab::Utils::Override

      override :execute
      def execute
        return super unless use_elasticsearch?

        ::Gitlab::Elastic::SnippetSearchResults.new(current_user,
                                                    params[:search],
                                                    projects)
      end

      override :elasticsearchable_resource
      def elasticsearchable_resource
        nil
      end
    end
  end
end
