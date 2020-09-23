# frozen_string_literal: true

module Gitlab
  module Geo
    module Replication
      # This class is responsible for:
      #   * Finding an Upload record
      #   * Requesting and downloading the Upload's file from the primary
      #   * Returning a detailed Result
      #
      class FileDownloader < BaseDownloader
        private

        def check_preconditions
          return missing_on_primary_error if resource && resource.model.nil?

          super
        end

        def local_store?
          resource.local?
        end

        def resource
          strong_memoize(:resource) { ::Upload.find_by_id(object_db_id) }
        end

        def transfer
          strong_memoize(:transfer) { ::Gitlab::Geo::Replication::FileTransfer.new(object_type.to_sym, resource) }
        end

        def object_store_enabled?
          ::FileUploader.object_store_enabled?
        end
      end
    end
  end
end
