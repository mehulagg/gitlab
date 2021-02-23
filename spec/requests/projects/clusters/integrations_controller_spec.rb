# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Projects::Clusters::IntegrationsController do
  describe 'POST create' do
    let(:cluster) { create(:cluster, :project, :provided_by_gcp) }
    let(:project) { cluster.project }
    let(:user) { create(:user) }
    let(:application) { Clusters::Applications::Prometheus.application_name }
    let(:enabled) { true }

    let(:params) do
      { integration: { application_type: application, enabled: enabled } }
    end

    before do
      project.add_maintainer(user)
      sign_in(user)
    end

    describe 'authorization' do

    end

    it 'creates a new Prometheus record' do
      post project_cluster_integrations_path(project, cluster), params: params

      expect(cluster.application_prometheus).to be_present
    end
  end
end
