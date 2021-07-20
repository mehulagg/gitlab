# frozen_string_literal: true

module Analytics
  module CycleAnalytics
    module ValueStreams
      class UpdateService < CreateService
        include Gitlab::Allowable

        private

        def process_params(raw_params)
          processed_params = super

          persisted_stage_ids.each do |stage_id|
            if to_be_deleted?(processed_params, stage_id)
              processed_params[:stages_attributes] << { id: stage_id, _destroy: '1' }
            end
          end

          processed_params
        end

        def persisted_stage_ids
          @persisted_stage_ids ||= value_stream.stages.pluck_primary_key
        end

        def to_be_deleted?(processed_params, stage_id)
          processed_params.has_key?(:stages_attributes) &&
          processed_params[:stages_attributes].none? { |attrs| attrs[:id] && Integer(attrs[:id]) == stage_id }
        end

        def success_http_status
          :ok
        end
      end
    end
  end
end
