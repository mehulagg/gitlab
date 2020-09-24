# frozen_string_literal: true

module Search
  module Elasticsearchable
    def use_elasticsearch?
      return false if params[:basic_search]
      return false if params[:scope] == 'users'

      ::Gitlab::CurrentSettings.search_using_elasticsearch?(scope: elasticsearchable_scope)
    end

    def elasticsearchable_scope
      raise NotImplementedError
    end
  end
end
