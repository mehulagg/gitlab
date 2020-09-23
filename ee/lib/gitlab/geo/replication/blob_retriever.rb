# frozen_string_literal: true

module Gitlab
  module Geo
    module Replication
      # Handles retrieval of a blob to be returned via the Geo API request
      #
      class BlobRetriever < BaseRetriever
        attr_reader :replicator, :checksum

        # @param [Gitlab::Geo::Replicator] replicator
        # @param [String] checksum
        def initialize(replicator:, checksum:)
          raise ArgumentError, 'Invalid replicator given' unless replicator.is_a?(Gitlab::Geo::Replicator)

          @replicator = replicator
          @checksum = checksum
        end

        def execute
          return error("#{replicator.replicable_name} not found") unless recorded_file
          return file_not_found(recorded_file) unless recorded_file.file_exist?
          return error('Checksum mismatch') unless matches_checksum?

          success(replicator.carrierwave_uploader)
        end

        private

        def recorded_file
          strong_memoize(:recorded_file) do
            replicator.model_record
          rescue ActiveRecord::RecordNotFound
            nil
          end
        end

        # Check if given checksum matches known good one
        #
        # We skip the check if no checksum is given to the retriever
        #
        # @return [Boolean]
        def matches_checksum?
          return true unless checksum

          replicator.matches_checksum?(checksum)
        end
      end
    end
  end
end
