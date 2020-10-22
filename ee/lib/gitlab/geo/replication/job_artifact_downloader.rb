# frozen_string_literal: true

module Gitlab
  module Geo
    module Replication
      # This class is responsible for:
      #   * Finding a ::Ci::JobArtifact record
      #   * Requesting and downloading the JobArtifact's file from the primary
      #   * Returning a detailed Result
      #
      class JobArtifactDownloader < BaseDownloader
        private

        def resource
          strong_memoize(:resource) { ::Ci::JobArtifact.find_by_id(object_db_id) }
        end

        def transfer
          strong_memoize(:transfer) { ::Gitlab::Geo::Replication::JobArtifactTransfer.new(resource) }
        end

        def object_store_enabled?
          ::JobArtifactUploader.object_store_enabled?
        end
      end
    end
  end
end
