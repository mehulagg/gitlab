# frozen_string_literal: true

require 'spec_helper'

RSpec.describe ProjectClusterablePresenter do
  include Gitlab::Routing.url_helpers

  let(:presenter) { described_class.new(project) }
  let(:cluster) { create(:cluster, :provided_by_gcp, :project) }
  let(:project) { cluster.project }

  describe '#metrics_cluster_path' do
    subject { presenter.metrics_cluster_path(cluster) }

    it { is_expected.to eq(metrics_project_cluster_path(project, cluster)) }
  end
end
