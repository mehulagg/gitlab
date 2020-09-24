# frozen_string_literal: true

module Geo
  class FileDownloadDispatchWorker # rubocop:disable Scalability/IdempotentWorker
    class LfsObjectJobFinder < JobFinder # rubocop:disable Scalability/IdempotentWorker
      RESOURCE_ID_KEY = :lfs_object_id
      EXCEPT_RESOURCE_IDS_KEY = :except_ids
      FILE_SERVICE_OBJECT_TYPE = :lfs

      def registry_finder
        @registry_finder ||= Geo::LfsObjectRegistryFinder.new
      end
    end
  end
end
