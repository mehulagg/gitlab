# frozen_string_literal: true

module EE
  module CycleAnalyticsParams
    extend ::Gitlab::Utils::Override
    include ::Gitlab::Utils::StrongMemoize

    override :options
    def options(params)
      strong_memoize(:options) do
        super.tap do |options|
          options[:branch] = params[:branch_name]
          options[:projects] = params[:project_ids] if params[:project_ids]
          options[:group] = params[:group_id] if params[:group_id]
          options[:from] = params[:from] if params[:from]
          options[:to] = params[:to] if params[:to]
          options[:end_event_filter] = params[:end_event_filter] if params[:end_event_filter]
          options.merge!(params.slice(*::Gitlab::Analytics::CycleAnalytics::RequestParams::FINDER_PARAM_NAMES))
        end
      end
    end

    private

    def permitted_cycle_analytics_params
      params.permit(*::Gitlab::Analytics::CycleAnalytics::RequestParams::STRONG_PARAMS_DEFINITION)
    end

    def all_cycle_analytics_params
      permitted_cycle_analytics_params.merge(current_user: current_user)
    end

    def request_params
      @request_params ||= ::Gitlab::Analytics::CycleAnalytics::RequestParams.new(all_cycle_analytics_params)
    end

    def validate_params
      if request_params.invalid?
        render(
          json: { message: 'Invalid parameters', errors: request_params.errors },
          status: :unprocessable_entity
        )
      end
    end
  end
end
