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
      search_service.allowed_scopes.include?('epics')
    end

    def show_elasticsearch_tabs?
      ::Gitlab::CurrentSettings.search_using_elasticsearch?(scope: search_service.elasticsearchable_scope)
    end
  end
end
