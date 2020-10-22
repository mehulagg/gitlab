# frozen_string_literal: true

module Gitlab
  module Geo
    module LogCursor
      module Events
        class LfsObjectDeletedEvent
          include BaseEvent

          def process
            # Must always schedule, regardless of shard health
            job_id = ::Geo::FileRegistryRemovalWorker.perform_async(:lfs, event.lfs_object_id, file_path)
            log_event(job_id)
          end

          private

          def file_path
            @file_path ||= File.join(LfsObjectUploader.root, event.file_path)
          end

          def log_event(job_id)
            super(
              'Delete LFS object scheduled',
              oid: event.oid,
              file_id: event.lfs_object_id,
              file_path: event.file_path,
              job_id: job_id)
          end
        end
      end
    end
  end
end
