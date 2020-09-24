# frozen_string_literal: true

module Elastic
  class IndexProjectsByRangeService
    DEFAULT_BATCH_SIZE = 1000
    BULK_PERFORM_SIZE = 1000

    def execute(start_id: nil, end_id: nil, batch_size: nil)
      end_id ||= ::Project.maximum(:id)

      return unless end_id

      start_id ||= 1
      batch_size ||= DEFAULT_BATCH_SIZE

      args = (start_id..end_id).each_slice(batch_size).map do |range|
        [range.first, range.last]
      end

      args.each_slice(BULK_PERFORM_SIZE) do |args|
        ElasticFullIndexWorker.bulk_perform_async(args) # rubocop:disable Scalability/BulkPerformWithContext
      end
    end
  end
end
