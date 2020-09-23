# frozen_string_literal: true

module Elastic
  module Latest
    class ProjectWikiInstanceProxy < ApplicationInstanceProxy
      include GitInstanceProxy

      delegate :project, to: :target
      delegate :id, to: :project, prefix: true

      # @return [Kaminari::PaginatableArray]
      def elastic_search_as_wiki_page(query, page: 1, per: 20, options: {})
        options = repository_specific_options(options)

        self.class.elastic_search_as_wiki_page(query, page: page, per: per, options: options)
      end

      private

      def repository_id
        "wiki_#{project.id}"
      end
    end
  end
end
