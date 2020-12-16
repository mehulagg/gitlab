# frozen_string_literal: true

require 'spec_helper'

RSpec.describe API::Ci::PrometheusMetrics do
  let_it_be(:developer) { create(:user) }
  let_it_be(:project) { create(:project) }

  before do
    project.add_developer(developer)
  end

  describe 'POST /projects/:id/prometheus_metrics/:metric_name' do
    let(:metric_name) { :draw_links }
    let(:params) { { duration: 5 } }

    it 'increments the metric' do
      post api("/projects/#{project.id}/prometheus_metrics/#{metric_name}", developer), params: params

      expect(response).to have_gitlab_http_status(:ok)
    end
  end
end
