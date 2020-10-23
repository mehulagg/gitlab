# frozen_string_literal: true

module Search
  module Elasticsearchable
    SCOPES_ONLY_BASIC_SEARCH = %w(users epics).freeze

    def use_elasticsearch?
      return false if params[:basic_search]
      return false if SCOPES_ONLY_BASIC_SEARCH.include?(params[:scope])

      ::Gitlab::CurrentSettings.search_using_elasticsearch?(resource: elasticsearchable_resource, scope: params[:scope])
    end

    def elasticsearchable_resource
      raise NotImplementedError
    end
  end
end
