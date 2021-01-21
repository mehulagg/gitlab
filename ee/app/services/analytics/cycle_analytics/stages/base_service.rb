# frozen_string_literal: true

module Analytics
  module CycleAnalytics
    module Stages
      class BaseService
        include Gitlab::Allowable

        DEFAULT_VALUE_STREAM_NAME = 'default'

        def initialize(parent:, current_user:, params: {})
          @parent = parent
          @current_user = current_user
          @params = params
        end

        def execute
          raise NotImplementedError
        end

        private

        attr_reader :parent, :current_user, :params

        def success(stage, http_status = :created)
          ServiceResponse.success(payload: { stage: stage }, http_status: http_status)
        end

        def error(stage)
          ServiceResponse.error(message: 'Invalid parameters', payload: { errors: stage.errors }, http_status: :unprocessable_entity)
        end

        def not_found
          ServiceResponse.error(message: 'Stage not found', payload: {}, http_status: :not_found)
        end

        def forbidden
          ServiceResponse.error(message: 'Forbidden', payload: {}, http_status: :forbidden)
        end

        def persist_default_stages!
          persisted_default_stages = parent.cycle_analytics_stages.by_value_stream(value_stream).default_stages

          # make sure that we persist default stages only once
          stages_to_persist = build_default_stages.select do |new_default_stage|
            !persisted_default_stages.find { |s| s.name.eql?(new_default_stage.name) }
          end

          stages_to_persist.each(&:save!)
        end

        def build_default_stages
          Gitlab::Analytics::CycleAnalytics::DefaultStages.all.map do |stage_params|
            parent.cycle_analytics_stages.build(stage_params.merge(value_stream: value_stream))
          end
        end

        def value_stream
          @value_stream ||= params[:value_stream] || parent.value_streams.safe_find_or_create_by!(name: DEFAULT_VALUE_STREAM_NAME)
        end
      end
    end
  end
end
