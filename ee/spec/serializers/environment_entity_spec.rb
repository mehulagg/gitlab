# frozen_string_literal: true

require 'spec_helper'

describe EnvironmentEntity do
  include KubernetesHelpers

  let(:user) { create(:user) }
  let(:environment) { create(:environment) }

  before do
    environment.project.add_maintainer(user)
  end

  let(:entity) do
    described_class.new(environment, request: double(current_user: user))
  end

  describe '#as_json' do
    subject { entity.as_json }

    context 'when deploy_boards are available' do
      before do
        stub_licensed_features(deploy_board: true)
      end

      context 'with deployment service ready' do
        before do
          allow(environment).to receive(:has_terminals?).and_return(true)
          allow(environment).to receive(:rollout_status).and_return(kube_deployment_rollout_status)
        end

        it 'exposes rollout_status' do
          expect(subject).to include(:rollout_status)
        end
      end
    end

    context 'when deploy_boards are not available' do
      before do
        allow(environment).to receive(:has_terminals?).and_return(true)
      end

      it 'does not expose rollout_status' do
        expect(subject).not_to include(:rollout_status)
      end
    end
  end
end
