# frozen_string_literal: true

module Gitlab
  module Geo
    module Replication
      # This class is responsible for:
      #   * Requesting an LfsObject file from the primary
      #   * Saving it in the right place on successful download
      #   * Returning a detailed Result object
      class LfsTransfer < BaseTransfer
        # Initialize a transfer service for a specified LfsObject
        #
        # @param [LfsObject] lfs_object
        def initialize(lfs_object)
          if lfs_object.local_store?
            super(local_lfs_object_attributes(lfs_object))
          else
            super(remote_lfs_object_attributes(lfs_object))
          end
        end

        private

        def uploader
          resource.file
        end

        def local_lfs_object_attributes(lfs_object)
          {
            resource: lfs_object,
            file_type: :lfs,
            file_id: lfs_object.id,
            filename: lfs_object.file.path,
            expected_checksum: lfs_object.oid,
            request_data: lfs_request_data(lfs_object)
          }
        end

        def remote_lfs_object_attributes(lfs_object)
          {
            resource: lfs_object,
            file_type: :lfs,
            file_id: lfs_object.id,
            expected_checksum: lfs_object.oid,
            request_data: lfs_request_data(lfs_object)
          }
        end

        def lfs_request_data(lfs_object)
          {
            checksum: lfs_object.oid,
            file_type: :lfs,
            file_id: lfs_object.id
          }
        end
      end
    end
  end
end
