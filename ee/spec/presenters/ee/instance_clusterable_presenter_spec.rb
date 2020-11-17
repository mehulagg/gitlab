# frozen_string_literal: true

require 'spec_helper'

RSpec.describe InstanceClusterablePresenter do
  include Gitlab::Routing.url_helpers

  let(:presenter) { described_class.new(instance) }
  let(:cluster) { create(:cluster, :provided_by_gcp, :instance) }
  let(:instance) { cluster.instance }

  describe '#metrics_cluster_path' do
    subject { presenter.metrics_cluster_path(cluster) }

    it { is_expected.to eq(metrics_admin_cluster_path(cluster)) }
  end
end
