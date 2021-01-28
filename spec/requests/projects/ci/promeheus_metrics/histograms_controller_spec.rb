# frozen_string_literal: true

require 'spec_helper'

RSpec.describe 'Projects::Ci::PrometheusMetrics::HistogramsController' do
  let_it_be(:project) { create(:project, :public) }

  describe 'POST /*namespace_id/:project_id/-/ci/prometheus_metrics/histograms' do
    context 'with known histograms' do
      it 'returns 201 Created' do
        post histograms_route(histograms: [{ name: :draw_links, duration: 5 }, { name: :other_metric, duration: 10 }])

        expect(response).to have_gitlab_http_status(:created)
      end
    end

    context 'with unknown histograms' do
      it 'returns 404 Not Found' do
        post histograms_route(histograms: [{ name: :chunky_bacon, duration: 5 }])

        expect(response).to have_gitlab_http_status(:not_found)
      end
    end
  end

  def histograms_route(params = {})
    namespace_project_ci_prometheus_metrics_histograms_path(namespace_id: project.namespace, project_id: project, **params)
  end
end
