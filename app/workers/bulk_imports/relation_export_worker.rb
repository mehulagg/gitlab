# frozen_string_literal: true

module BulkImports
  class RelationExportWorker # rubocop:disable Scalability/IdempotentWorker
    include ApplicationWorker
    include ExceptionBacktrace

    feature_category :importers
    loggable_arguments 2
    sidekiq_options retry: false, dead: false

    def perform(current_user_id, group_id, params = {})
      current_user = User.find(current_user_id)

    end
  end
end
