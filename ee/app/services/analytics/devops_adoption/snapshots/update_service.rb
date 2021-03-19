# frozen_string_literal: true

module Analytics
  module DevopsAdoption
    module Snapshots
      class UpdateService
        ALLOWED_ATTRIBUTES = [
          :segment,
          :segment_id,
          :end_time,
          :recorded_at,
          :issue_opened,
          :merge_request_opened,
          :merge_request_approved,
          :runner_configured,
          :pipeline_succeeded,
          :deploy_succeeded,
          :security_scan_succeeded
        ].freeze

        def initialize(snapshot:, params: {})
          @snapshot = snapshot
          @params = params
        end

        def execute
          success = false

          ActiveRecord::Base.transaction do
            snapshot.assign_attributes(attributes)

            success = snapshot.save && snapshot.segment.update(last_recorded_at: snapshot.recorded_at)

            raise ActiveRecord::Rollback unless success
          end

          if success
            ServiceResponse.success(payload: response_payload)
          else
            ServiceResponse.error(message: 'Validation error', payload: response_payload)
          end
        end

        private

        attr_reader :snapshot, :params

        def response_payload
          { snapshot: snapshot }
        end

        def attributes
          params.slice(*ALLOWED_ATTRIBUTES)
        end
      end
    end
  end
end
