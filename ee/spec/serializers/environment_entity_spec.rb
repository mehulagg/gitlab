# frozen_string_literal: true

require 'spec_helper'

describe EnvironmentEntity do
  include KubernetesHelpers

  let(:user) { create(:user) }
  let(:environment) { create(:environment) }
  let(:project) { create(:project) }

  let(:entity) do
    described_class.new(environment, request: double(current_user: user, project: project))
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
          environment.project.add_maintainer(user)
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

    context 'when environment has a review app' do
      let(:project) { create(:project, :repository) }
      let(:environment) { create(:environment, :with_review_app, ref: 'development', project: project) }
      let(:protected_environment) { create(:protected_environment, name: environment.name, project: project) }

      before do
        project.repository.add_branch(user, 'development', project.commit.id)
      end

      describe '#can_stop' do
        subject { entity.as_json[:can_stop] }

        it_behaves_like 'protected environments access'
      end

      describe '#terminal_path' do
        before do
          allow(environment).to receive(:has_terminals?).and_return(true)
        end

        subject { entity.as_json.include?(:terminal_path) }

        it_behaves_like 'protected environments access', false
      end
    end
  end
end
