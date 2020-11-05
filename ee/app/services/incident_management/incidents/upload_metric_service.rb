# frozen_string_literal: true

module IncidentManagement
  module Incidents
    class UploadMetricService < BaseService
      def initialize(issuable, current_user, params = {})
        super

        @issuable = issuable
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

      attr_reader :issuable, :file, :url, :metric

      private

      def upload_metric
        @metric = IncidentManagement::MetricImage.create!(
          incident: issuable,
          file: file,
          url: url
        )
      end

      def can_upload_metrics?
        Ability.allowed?(current_user, :upload_metric, issuable)
      end
    end
  end
end
