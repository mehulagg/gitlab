# frozen_string_literal: true

module Analytics
  module CycleAnalytics
    module ValueStreams
      class CreateService
        def initialize(group:, params:)
          @group = group
          @params = process_params(params)
        end

        def execute
          value_stream = group.value_streams.create(params)

          if value_stream.persisted?
            ServiceResponse.success(message: nil, payload: { value_stream: value_stream }, http_status: :created)
          else
            ServiceResponse.error(message: nil, payload: { errors: value_stream.errors }, http_status: :unprocessable_entity)
          end
        end

        private

        attr_reader :group, :params

        def process_params(raw_params)
          if raw_params[:stages]
            raw_params[:stages_attributes] = raw_params.delete(:stages)
            raw_params[:stages_attributes].map! { |attrs| build_stage_attributes(attrs) }
          end

          raw_params
        end

        def build_stage_attributes(stage_attributes)
          stage_attributes[:group] = group
          return stage_attributes if stage_attributes[:custom]

          use_default_stage_params(stage_attributes)
        end

        def use_default_stage_params(stage_attributes)
          default_stage_attributes = Gitlab::Analytics::CycleAnalytics::DefaultStages.find_by_name!(stage_attributes[:name])
          stage_attributes.merge(default_stage_attributes)
        end
      end
    end
  end
end
