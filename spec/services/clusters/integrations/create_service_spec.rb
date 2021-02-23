# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Clusters::Integrations::CreateService, '#execute' do
  let_it_be(:project) { create(:project) }
  let_it_be(:cluster) { create(:cluster, :provided_by_gcp, projects: [project]) }

  let(:params) do
    { application_type: 'prometheus', enabled: true }
  end

  let(:service) do
    described_class.new(container: project, cluster: cluster, current_user: project.owner, params: params)
  end

  it 'creates a new Prometheus instance' do
    service.execute

    expect(cluster.application_prometheus).to be_present
    expect(cluster.application_prometheus).to be_persisted
    expect(cluster.application_prometheus).to be_installed

    # WINCE
    puts cluster.application_prometheus.version
  end

  context 'application_prometheues record exists' do
    it 'updates the Prometheus instance' do
    end
  end

  context 'for an un-supported application type' do
    let(:params) do
      { application_type: 'something_else', enabled: true }
    end

    it 'errors' do
      expect { service.execute}.to raise_error(described_class::InvalidApplicationError)
    end
  end
end
