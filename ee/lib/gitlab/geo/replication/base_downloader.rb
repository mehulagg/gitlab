# frozen_string_literal: true

module Gitlab
  module Geo
    module Replication
      class BaseDownloader
        include ::Gitlab::Utils::StrongMemoize

        attr_reader :object_type, :object_db_id

        class Result
          attr_reader :success, :bytes_downloaded, :primary_missing_file, :failed_before_transfer, :reason

          def self.from_transfer_result(transfer_result)
            Result.new(success: transfer_result.success,
                       primary_missing_file: transfer_result.primary_missing_file,
                       bytes_downloaded: transfer_result.bytes_downloaded)
          end

          def initialize(success:, bytes_downloaded:, reason: nil, primary_missing_file: false, failed_before_transfer: false)
            @success = success
            @bytes_downloaded = bytes_downloaded
            @primary_missing_file = primary_missing_file
            @failed_before_transfer = failed_before_transfer
            @reason = reason
          end
        end

        def initialize(object_type, object_db_id)
          @object_type = object_type
          @object_db_id = object_db_id
        end

        def execute
          check_result = check_preconditions
          return check_result if check_result

          result = if local_store?
                     transfer.download_from_primary
                   else
                     transfer.stream_from_primary_to_object_storage
                   end

          Result.from_transfer_result(result)
        end

        private

        def check_preconditions
          unless resource.present?
            return skip_transfer_error(reason: "Skipping transfer as the #{object_type.to_s.humanize(capitalize: false)} (ID = #{object_db_id}) could not be found")
          end

          unless local_store?
            unless sync_object_storage_enabled?
              return skip_transfer_error(reason: "Skipping transfer as this secondary node is not allowed to replicate content on Object Storage")
            end

            unless object_store_enabled?
              return skip_transfer_error(reason: "Skipping transfer as this secondary node is not configured to store #{object_type.to_s.humanize(capitalize: false)} on Object Storage")
            end
          end

          nil
        end

        def local_store?
          resource.local_store?
        end

        def resource
          raise NotImplementedError, "#{self.class} does not implement #{__method__}"
        end

        def transfer
          raise NotImplementedError, "#{self.class} does not implement #{__method__}"
        end

        def object_store_enabled?
          raise NotImplementedError, "#{self.class} does not implement #{__method__}"
        end

        def sync_object_storage_enabled?
          Gitlab::Geo.current_node.sync_object_storage
        end

        def skip_transfer_error(reason: nil)
          Result.new(success: false, bytes_downloaded: 0, reason: reason, failed_before_transfer: true)
        end

        def missing_on_primary_error
          Result.new(success: true, bytes_downloaded: 0, primary_missing_file: true)
        end
      end
    end
  end
end
