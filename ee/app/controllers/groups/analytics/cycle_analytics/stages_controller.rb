# frozen_string_literal: true

module Groups
  module Analytics
    module CycleAnalytics
      class StagesController < Groups::Analytics::ApplicationController
        include CycleAnalyticsParams
        extend ::Gitlab::Utils::Override

        before_action :load_group
        before_action :load_value_stream
        before_action :validate_params, only: %i[median average records average_duration_chart count]
        before_action :authorize_read_group_stage, only: %i[median average records average_duration_chart count]

        def index
          return render_403 unless can?(current_user, :read_group_cycle_analytics, @group)

          result = list_service.execute

          if result.success?
            render json: cycle_analytics_configuration(result.payload[:stages])
          else
            render json: { message: result.message }, status: result.http_status
          end
        end

        def create
          return render_403 unless can?(current_user, :create_group_stage, @group)

          render_stage_service_result(create_service.execute)
        end

        def update
          return render_403 unless can?(current_user, :update_group_stage, @group)

          render_stage_service_result(update_service.execute)
        end

        def destroy
          return render_403 unless can?(current_user, :delete_group_stage, @group)

          render_stage_service_result(delete_service.execute)
        end

        def median
          render json: { value: data_collector.median.seconds }
        end

        def average
          render json: { value: data_collector.average.seconds }
        end

        def records
          serialized_records = data_collector.serialized_records do |relation|
            add_pagination_headers(relation)
          end

          render json: serialized_records
        end

        def average_duration_chart
          render json: ::Analytics::CycleAnalytics::DurationChartAverageItemEntity.represent(data_collector.duration_chart_average_data)
        end

        def count
          render json: { count: data_collector.count }
        end

        private

        def data_collector
          @data_collector ||= Gitlab::Analytics::CycleAnalytics::DataCollector.new(
            stage: stage,
            params: request_params.to_data_collector_params
          )
        end

        def stage
          @stage ||= ::Analytics::CycleAnalytics::StageFinder.new(parent: @group, stage_id: params[:id]).execute
        end

        def cycle_analytics_configuration(stages)
          stage_presenters = stages.map { |s| ::Analytics::CycleAnalytics::StagePresenter.new(s) }

          ::Analytics::CycleAnalytics::ConfigurationEntity.new(stages: stage_presenters)
        end

        def list_service
          ::Analytics::CycleAnalytics::Stages::ListService.new(parent: @group, current_user: current_user, params: list_params)
        end

        def create_service
          ::Analytics::CycleAnalytics::Stages::CreateService.new(parent: @group, current_user: current_user, params: create_params)
        end

        def update_service
          ::Analytics::CycleAnalytics::Stages::UpdateService.new(parent: @group, current_user: current_user, params: update_params)
        end

        def delete_service
          ::Analytics::CycleAnalytics::Stages::DeleteService.new(parent: @group, current_user: current_user, params: delete_params)
        end

        def render_stage_service_result(result)
          if result.success?
            stage = ::Analytics::CycleAnalytics::StagePresenter.new(result.payload[:stage])
            render json: ::Analytics::CycleAnalytics::StageEntity.new(stage), status: result.http_status
          else
            render json: { message: result.message, errors: result.payload[:errors] }, status: result.http_status
          end
        end

        override :all_cycle_analytics_params
        def all_cycle_analytics_params
          super.merge({ group: @group })
        end

        def list_params
          { value_stream: @value_stream }
        end

        def update_params
          params.permit(:name, :start_event_identifier, :end_event_identifier, :id, :move_after_id, :move_before_id, :hidden, :start_event_label_id, :end_event_label_id).merge(list_params)
        end

        def create_params
          params.permit(:name, :start_event_identifier, :end_event_identifier, :start_event_label_id, :end_event_label_id).merge(list_params)
        end

        def delete_params
          params.permit(:id)
        end

        def load_value_stream
          if params[:value_stream_id] && params[:value_stream_id] != ::Analytics::CycleAnalytics::Stages::BaseService::DEFAULT_VALUE_STREAM_NAME
            @value_stream = @group.value_streams.find(params[:value_stream_id])
          end
        end

        def add_pagination_headers(relation)
          Gitlab::Pagination::OffsetHeaderBuilder.new(
            request_context: self,
            per_page: relation.limit_value,
            page: relation.current_page,
            next_page: relation.next_page,
            prev_page: relation.prev_page,
            params: permitted_cycle_analytics_params
          ).execute(exclude_total_headers: true, data_without_counts: true)
        end

        def authorize_read_group_stage
          return render_403 unless can?(current_user, :delete_group_stage, @group)
        end
      end
    end
  end
end
