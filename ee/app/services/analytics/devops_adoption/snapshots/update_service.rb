# frozen_string_literal: true

module Analytics
  module DevopsAdoption
    module Snapshots
      class UpdateService
        ALLOWED_ATTRIBUTES = ([
          :namespace,
          :namespace_id,
          :end_time,
          :recorded_at
        ] + Snapshot::ADOPTION_METRICS).freeze

        def initialize(snapshot:, params: {})
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
