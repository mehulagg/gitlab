# frozen_string_literal: true

module IncidentManagement
  module Incidents
    class UploadMetricService < BaseService
      def initialize(issuable, current_user, params = {})
        super

        @issuable = issuable
        @project = issuable&.project
        @file = params.fetch(:file)
        @url = params.fetch(:url, nil)
      end

      def execute
        return ServiceResponse.error(message: "Not allowed!") unless issuable.metric_images_available? && can_upload_metrics?

        upload_metric

        ServiceResponse.success(payload: { metric: metric, issuable: issuable })
      rescue ::ActiveRecord::RecordInvalid => e
        ServiceResponse.error(message: e.message)
      end

      attr_reader :issuable, :project, :file, :url, :metric

      private

      def upload_metric
        @metric = IssuableMetricImage.create!(
          issue: issuable,
          file: file,
          url: url
        )
      end

      def can_upload_metrics?
        current_user&.can?(:upload_issuable_metric_image, issuable)
      end
    end
  end
end
