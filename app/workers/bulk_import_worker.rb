# frozen_string_literal: true

class BulkImportWorker # rubocop:disable Scalability/IdempotentWorker
  include ApplicationWorker

  feature_category :importers

  sidekiq_options retry: false, dead: false

  worker_has_external_dependencies!

  def perform(bulk_import_id)
    @bulk_import = BulkImport.find(bulk_import_id)

    @bulk_import.start! unless @bulk_import.started?

    if entities_to_import.empty?
      @bulk_import.finish!
    else
      entities_to_import.each { |entity| entity.start! }

      # A new BulkImportWorker job is enqueued to either
      #   - Process the new BulkImports::Entity created for the subgroups
      #   - Or to mark the `bulk_import` as finished.
      BulkImportWorker.perform_async(@bulk_import.id)
    end
  end

  private

  def entities_to_import
    @entities_to_import ||= @bulk_import.entities.with_status(:created)
  end
end
