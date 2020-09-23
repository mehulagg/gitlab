# frozen_string_literal: true

module Elastic
  module ProjectsSearch
    extend ActiveSupport::Concern

    include ApplicationVersionedSearch

    included do
      def use_elasticsearch?
        ::Gitlab::CurrentSettings.elasticsearch_indexes_project?(self)
      end

      def maintain_elasticsearch_create
        ::Elastic::ProcessInitialBookkeepingService.track!(self)
      end

      def maintain_elasticsearch_destroy
        ElasticDeleteProjectWorker.perform_async(self.id, self.es_id)
      end
    end
  end
end
