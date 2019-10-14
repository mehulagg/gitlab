# frozen_string_literal: true

module EE
  module Clusters
    module ClustersController
      include MetricsDashboard
      extend ActiveSupport::Concern

      prepended do
        before_action :authorize_read_prometheus!, only: :prometheus_proxy
      end

      def metrics
        return render_404 unless prometheus_adapter&.can_query?

        respond_to do |format|
          format.json do
            metrics = prometheus_adapter.query(:cluster) || {}

            if metrics.any?
              render json: metrics
            else
              head :no_content
            end
          end
        end
      end

      def prometheus_proxy
        result = ::Prometheus::ProxyService.new(
          cluster.cluster,
          proxy_method,
          proxy_path,
          proxy_params
        ).execute

        if result.nil?
          return render status: :no_content, json: {
            status: _('processing'),
            message: _('Not ready yet. Try again later.')
          }
        end

        if result[:status] == :success
          render status: result[:http_status], json: result[:body]
        else
          render(
            status: result[:http_status] || :bad_request,
            json: { status: result[:status], message: result[:message] }
          )
        end
      end

      private

      def prometheus_adapter
        return unless cluster&.application_prometheus_available?

        cluster.application_prometheus
      end

      def proxy_method
        request.method
      end

      def proxy_path
        params[:proxy_path]
      end

      def proxy_params
        params.permit!
      end
    end
  end
end
