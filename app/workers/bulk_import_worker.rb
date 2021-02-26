# frozen_string_literal: true

class BulkImportWorker # rubocop:disable Scalability/IdempotentWorker
  include ApplicationWorker

  feature_category :importers

  idempotent!
  # Only one job for per BulkImport can be enqueued per time.
  # This will avoid processing the same entity more than once
  # and avoid
  deduplicate :until_executing

  PERFORM_DELAY = 5.seconds
  DEFAULT_BATCH_SIZE = 5

  def perform(bulk_import_id)
    @bulk_import = BulkImport.find_by_id(bulk_import_id)

    return if @bulk_import.blank? || @bulk_import.finished?

    @bulk_import.start! if @bulk_import.created?

    BulkImports::EntityWorker.bulk_perform_in(
      PERFORM_DELAY,
      @bulk_import.entities.with_status(:created).pluck(:id),
      batch_size: DEFAULT_BATCH_SIZE,
      batch_delay: PERFORM_DELAY
    )
  rescue => e
    Gitlab::ErrorTracking.track_exception(e, bulk_import_id: @bulk_import&.id)

    @bulk_import&.fail_op
  end
end
