# frozen_string_literal: true

module Projects
  module Security
    class WafAnomaliesController < Projects::ApplicationController
      POLLING_INTERVAL = 5_000

      before_action :authorize_read_waf_anomalies!
      before_action :set_polling_interval

      def summary
        return not_found unless anomaly_summary_service.elasticsearch_client

        result = anomaly_summary_service.execute

        respond_to do |format|
          format.json do
            status = result[:status] == :success ? :ok : :bad_request
            render status: status, json: result
          end
        end
      end

      private

      def anomaly_summary_service
        @anomaly_summary_service ||= ::Security::WafAnomalySummaryService.new(
          environment: environment,
          **query_params.to_h.symbolize_keys
        )
      end

      def query_params
        params.permit(:interval, :from, :to)
      end

      def set_polling_interval
        Gitlab::PollingInterval.set_header(response, interval: POLLING_INTERVAL)
      end

      def environment
        @environment ||= project.environments.find(params.delete("environment_id"))
      end

      def authorize_read_waf_anomalies!
        render_403 unless can?(current_user, :read_threat_monitoring, project)
      end
    end
  end
end
