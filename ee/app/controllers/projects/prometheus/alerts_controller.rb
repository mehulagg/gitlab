# frozen_string_literal: true

module Projects
  module Prometheus
    class AlertsController < Projects::ApplicationController
      respond_to :json

      protect_from_forgery except: [:notify]

      before_action :authorize_read_prometheus_alerts!, except: [:notify]
      before_action :authorize_admin_project!, except: [:notify]
      before_action :alert, only: [:update, :show, :destroy]

      # rubocop: disable CodeReuse/ActiveRecord
      def index
        alerts = project.prometheus_alerts.reorder(id: :asc)

        render json: serialize_as_json(alerts)
      end
      # rubocop: enable CodeReuse/ActiveRecord

      def show
        render json: serialize_as_json(alert)
      end

      def notify
        token = extract_alert_manager_token(request)
        notify = Projects::Prometheus::Alerts::NotifyService.new(project, current_user, params)

        if notify.execute(token)
          head :ok
        else
          head :unprocessable_entity
        end
      end

      def create
        @alert = project.prometheus_alerts.create(alerts_params)

        if @alert.persisted?
          schedule_prometheus_update!

          render json: serialize_as_json(@alert)
        else
          head :no_content
        end
      end

      def update
        if alert.update(alerts_params)
          schedule_prometheus_update!

          render json: serialize_as_json(alert)
        else
          head :no_content
        end
      end

      def destroy
        if alert.destroy
          schedule_prometheus_update!

          head :ok
        else
          head :no_content
        end
      end

      private

      def alerts_params
        alerts_params = params.permit(:operator, :threshold, :environment_id, :prometheus_metric_id)

        if alerts_params[:operator].present?
          alerts_params[:operator] = PrometheusAlert.operator_to_enum(alerts_params[:operator])
        end

        alerts_params
      end

      def schedule_prometheus_update!
        ::Clusters::Applications::ScheduleUpdateService.new(application, project).execute
      end

      def serialize_as_json(alert_obj)
        serializer.represent(alert_obj)
      end

      def serializer
        PrometheusAlertSerializer.new(project: project, current_user: current_user)
      end

      def alert
        @alert ||= project.prometheus_alerts.for_metric(params[:id]).first || render_404
      end

      def application
        @application ||= alert.environment.cluster_prometheus_adapter
      end

      def extract_alert_manager_token(request)
        Doorkeeper::OAuth::Token.from_bearer_authorization(request)
      end
    end
  end
end
