# frozen_string_literal: true

module MergeRequests
  class AddSpentTimeService < UpdateService
    def execute(merge_request)
      # Do not touch when saving the issuable if only changes position within a list. We should call
      # this method at this point to capture all possible changes.
      should_touch = update_timestamp?(merge_request)

      merge_request.spend_time(params[:spend_time])

      merge_request_saved = merge_request.with_transaction_returning_status do
        merge_request.save(touch: should_touch)
      end

      merge_request
    end
  end
end
