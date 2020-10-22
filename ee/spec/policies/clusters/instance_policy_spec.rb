# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Clusters::InstancePolicy, :enable_admin_mode do
  let(:user) { build(:admin) }
  let(:instance) { Clusters::Instance.new }

  subject { described_class.new(user, instance) }

  context 'when cluster deployments is available' do
    before do
      stub_licensed_features(cluster_deployments: true)
    end

    it { is_expected.to be_allowed(:read_cluster_environments) }
  end

  context 'when cluster deployments is unavailable' do
    before do
      stub_licensed_features(cluster_deployments: false)
    end

    it { is_expected.not_to be_allowed(:read_cluster_environments) }
  end
end
