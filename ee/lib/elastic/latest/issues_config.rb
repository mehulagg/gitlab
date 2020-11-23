# frozen_string_literal: true

module Elastic
  module Latest
    module IssuesConfig
      # To obtain settings and mappings methods
      extend Elasticsearch::Model::Indexing::ClassMethods
      extend Elasticsearch::Model::Naming::ClassMethods

      # ES6 requires a single type per index
      self.document_type = 'issue'
      self.index_name = [document_type, Rails.env].join('-')

      settings \
        index: {
          number_of_shards: Elastic::AsJSON.new { Gitlab::CurrentSettings.elasticsearch_shards }
        }
    end
  end
end
