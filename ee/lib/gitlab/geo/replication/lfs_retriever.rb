# frozen_string_literal: true

module Gitlab
  module Geo
    module Replication
      # This class is responsible for:
      #   * Finding an LfsObject record
      #   * Returning the necessary response data to send the file back
      #
      class LfsRetriever < BaseRetriever
        def execute
          return error('Invalid request') unless valid?
          return error('LFS object not found') unless lfs_object
          return error('LFS object not found') unless matches_checksum?

          unless lfs_object.file.present? && lfs_object.file.exists?
            log_error("Could not upload LFS object because it does not have a file", id: lfs_object.id)

            return file_not_found(lfs_object)
          end

          success(lfs_object.file)
        end

        private

        def lfs_object
          strong_memoize(:lfs_object) do
            LfsObject.find_by_id(object_db_id)
          end
        end

        def valid?
          !extra_params.nil?
        end

        def matches_checksum?
          extra_params[:checksum] == lfs_object.oid
        end
      end
    end
  end
end
