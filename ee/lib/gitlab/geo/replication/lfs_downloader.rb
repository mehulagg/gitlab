# frozen_string_literal: true

module Gitlab
  module Geo
    module Replication
      # This class is responsible for:
      #   * Finding a LfsObject record
      #   * Requesting and downloading the LfsObject's file from the primary
      #   * Returning a detailed Result
      #
      class LfsDownloader < BaseDownloader
        private

        def resource
          strong_memoize(:resource) { ::LfsObject.find_by_id(object_db_id) }
        end

        def transfer
          strong_memoize(:transfer) { ::Gitlab::Geo::Replication::LfsTransfer.new(resource) }
        end

        def object_store_enabled?
          ::LfsObjectUploader.object_store_enabled?
        end
      end
    end
  end
end
