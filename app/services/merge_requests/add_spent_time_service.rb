# frozen_string_literal: true

module MergeRequests
  class AddSpentTimeService < UpdateService
    def execute(merge_request)
      old_associations = associations_before_update(merge_request)

      merge_request.spend_time(params[:spend_time])

      merge_request_saved = merge_request.with_transaction_returning_status do
        merge_request.save
      end

      if merge_request_saved
        create_system_notes(merge_request)

        # track usage
        old_timelogs = old_associations.fetch(:timelogs, [])
        changed_fields = merge_request.previous_changes.keys
        track_time_estimate_and_spend_edits(merge_request, old_timelogs, changed_fields)

        execute_hooks(merge_request, 'update', old_associations: old_associations)
      end

      merge_request
    end
  end
end
