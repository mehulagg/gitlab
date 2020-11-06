# frozen_string_literal: true

module IncidentManagement
  module Incidents
    class UploadMetricService < BaseService
      def initialize(issuable, current_user, params = {})
        super

        @issuable = issuable
        @project = issuable&.project
        @file = params.fetch(:file)
        @url = params.fetch(:url)
      end

      def execute
        return error("Not allowed!") unless can_upload_metrics?

        upload_metric

        success(metric: metric, issuable: issuable)
      rescue ::ActiveRecord::RecordInvalid => e
        error(e.message)
      end

      attr_reader :issuable, :project, :file, :url, :metric

      private

      def upload_metric
        @metric = IncidentManagement::MetricImage.create!(
          incident: issuable,
          file: file,
          url: url
        )
      end

      def can_upload_metrics?
        project.feature_available?(:incident_metric_upload) &&
          Ability.allowed?(current_user, :upload_metric, issuable)
      end
    end
  end
end
