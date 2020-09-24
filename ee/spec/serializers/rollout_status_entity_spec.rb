# frozen_string_literal: true

require 'spec_helper'

RSpec.describe RolloutStatusEntity do
  include KubernetesHelpers

  let(:rollout_status) { kube_deployment_rollout_status }

  let(:entity) do
    described_class.new(rollout_status, request: double)
  end

  subject { entity.as_json }

  it "exposes status" do
    is_expected.to include(:status)
  end

  it 'exposes has_legacy_app_label' do
    is_expected.to include(:has_legacy_app_label)
  end

  context 'when kube deployment is valid' do
    it "exposes deployment data" do
      is_expected.to include(:instances, :completion, :is_completed)
    end
  end

  context 'when kube deployment is empty' do
    let(:rollout_status) { empty_deployment_rollout_status }

    it "exposes status" do
      is_expected.to include(:status)
    end

    it "does not expose deployment data" do
      is_expected.not_to include(:instances, :completion, :is_completed)
    end
  end
end
