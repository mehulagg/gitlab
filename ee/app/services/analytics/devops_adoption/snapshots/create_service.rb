# frozen_string_literal: true

module Analytics
  module DevopsAdoption
    module Snapshots
      class CreateService
        ALLOWED_ATTRIBUTES = [
          :segment,
          :segment_id,
          :recorded_at,
          :issue_opened,
          :merge_request_opened,
          :merge_request_approved,
          :runner_configured,
          :pipeline_succeeded,
          :deploy_succeeded,
          :security_scan_succeeded
        ].freeze

        def initialize(snapshot: Analytics::DevopsAdoption::Snapshot.new, params: {})
          @snapshot = snapshot
          @params = params
        end

        def execute
          snapshot.assign_attributes(attributes)

          if snapshot.save
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
