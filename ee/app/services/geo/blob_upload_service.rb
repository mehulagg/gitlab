# frozen_string_literal: true

module Geo
  class BlobUploadService
    attr_reader :checksum, :replicator

    def initialize(replicable_name:, replicable_id:, decoded_params:)
      @checksum = decoded_params.delete(:checksum)

      @replicator = Gitlab::Geo::Replicator.for_replicable_params(replicable_name: replicable_name, replicable_id: replicable_id)
    end

    def execute
      retriever.execute
    end

    def retriever
      Gitlab::Geo::Replication::BlobRetriever.new(replicator: replicator, checksum: checksum)
    end
  end
end
