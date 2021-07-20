# frozen_string_literal: true

module EE
  module Analytics
    module CycleAnalytics
      module Stages
        module BaseService
          extend ::Gitlab::Utils::Override

          private

          def error(stage)
            ServiceResponse.error(message: 'Invalid parameters', payload: { errors: stage.errors }, http_status: :unprocessable_entity)
          end

          def not_found
            ServiceResponse.error(message: 'Stage not found', http_status: :not_found)
          end

          def persist_default_stages!
            persisted_default_stages = parent.cycle_analytics_stages.by_value_stream(value_stream).default_stages

            # make sure that we persist default stages only once
            stages_to_persist = build_default_stages.select do |new_default_stage|
              !persisted_default_stages.find { |s| s.name.eql?(new_default_stage.name) }
            end

            stages_to_persist.each(&:save!)
          end

          override :value_stream
          def value_stream
            @value_stream ||= params[:value_stream] || parent.value_streams.safe_find_or_create_by!(name: ::Analytics::CycleAnalytics::Stages::BaseService::DEFAULT_VALUE_STREAM_NAME)
          end
        end
      end
    end
  end
end
