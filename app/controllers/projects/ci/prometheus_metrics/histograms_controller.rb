# frozen_string_literal: true

module Projects
  module Ci
    module PrometheusMetrics
      class HistogramsController < Projects::ApplicationController
        respond_to :json, only: [:create]

        def create
          result = ::Ci::PrometheusMetrics::ObserveHistogramsService.new(project, permitted_params).execute

          render json: result.body, status: result.status
        end

        private

        def permitted_params
          params.permit(histograms: [:name, :duration])
        end
      end
    end
  end
end
