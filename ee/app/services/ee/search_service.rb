# frozen_string_literal: true

module EE
  module SearchService
    # This is a proper method instead of a `delegate` in order to
    # avoid adding unnecessary methods to Search::SnippetService
    def use_elasticsearch?
      search_service.use_elasticsearch?
    end

    def valid_query_length?
      return true if use_elasticsearch?

      super
    end

    def valid_terms_count?
      return true if use_elasticsearch?

      super
    end

    def show_epics?
      return false unless ::Feature.enabled?(:epics_search)
      return false unless ::License.feature_available?(:epics)

      true
    end
  end
end
