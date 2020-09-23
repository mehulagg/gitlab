# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Environment, :use_clean_rails_memory_store_caching do
  include ReactiveCachingHelpers

  let(:project) { create(:project, :repository) }
  let(:environment) { create(:environment, project: project) }

  describe '.deployed_to_cluster' do
    let!(:environment) { create(:environment) }

    context 'when there is no deployment' do
      let(:cluster) { create(:cluster) }

      it 'returns nothing' do
        expect(described_class.deployed_to_cluster(cluster)).to be_empty
      end
    end

    context 'when there is a deployment for the cluster' do
      let(:cluster) { last_deployment.cluster }

      let(:last_deployment) do
        create(:deployment, :success, :on_cluster, environment: environment)
      end

      it 'returns the environment for the last deployment' do
        expect(described_class.deployed_to_cluster(cluster)).to eq([environment])
      end
    end

    context 'when there is a non-cluster deployment' do
      let(:cluster) { create(:cluster) }

      before do
        create(:deployment, :success, environment: environment)
      end

      it 'returns nothing' do
        expect(described_class.deployed_to_cluster(cluster)).to be_empty
      end
    end

    context 'when the non-cluster deployment is latest' do
      let(:cluster) { create(:cluster) }

      before do
        create(:deployment, :success, cluster: cluster, environment: environment)
        create(:deployment, :success, environment: environment)
      end

      it 'returns nothing' do
        expect(described_class.deployed_to_cluster(cluster)).to be_empty
      end
    end
  end

  describe '#protected?' do
    subject { environment.protected? }

    before do
      stub_licensed_features(protected_environments: feature_available)
    end

    context 'when Protected Environments feature is not available on the project' do
      let(:feature_available) { false }

      it { is_expected.to be_falsy }
    end

    context 'when Protected Environments feature is available on the project' do
      let(:feature_available) { true }

      context 'when the environment is protected' do
        before do
          create(:protected_environment, name: environment.name, project: project)
        end

        it { is_expected.to be_truthy }
      end

      context 'when the environment is not protected' do
        it { is_expected.to be_falsy }
      end
    end
  end

  describe '#protected_deployable_by_user?' do
    let(:user) { create(:user) }
    let(:protected_environment) { create(:protected_environment, :maintainers_can_deploy, name: environment.name, project: project) }

    subject { environment.protected_deployable_by_user?(user) }

    before do
      stub_licensed_features(protected_environments: true)
    end

    context 'when Protected Environments feature is not available on the project' do
      let(:feature_available) { false }

      it { is_expected.to be_truthy }
    end

    context 'when Protected Environments feature is available on the project' do
      let(:feature_available) { true }

      context 'when the environment is not protected' do
        it { is_expected.to be_truthy }
      end

      context 'when environment is protected and user dont have access to it' do
        before do
          protected_environment
        end

        it { is_expected.to be_falsy }
      end

      context 'when environment is protected and user have access to it' do
        before do
          protected_environment.deploy_access_levels.create(user: user)
        end

        it { is_expected.to be_truthy }
      end
    end
  end

  describe '#reactive_cache_updated' do
    let(:mock_store) { double }

    subject { environment.reactive_cache_updated }

    it 'expires the environments path for the project' do
      expect(::Gitlab::EtagCaching::Store).to receive(:new).and_return(mock_store)
      expect(mock_store).to receive(:touch).with(::Gitlab::Routing.url_helpers.project_environments_path(project, format: :json))

      subject
    end

    context 'with a group cluster' do
      let(:cluster) { create(:cluster, :group) }

      before do
        create(:deployment, :success, environment: environment, cluster: cluster)
      end

      it 'expires the environments path for the group cluster' do
        expect_next_instance_of(Gitlab::EtagCaching::Store) do |store|
          expect(store).to receive(:touch)
            .with(::Gitlab::Routing.url_helpers.project_environments_path(project, format: :json))
            .and_call_original

          expect(store).to receive(:touch)
            .with(::Gitlab::Routing.url_helpers.environments_group_cluster_path(cluster.group, cluster))
            .and_call_original
        end

        subject
      end
    end

    context 'with an instance cluster' do
      let(:cluster) { create(:cluster, :instance) }

      before do
        create(:deployment, :success, environment: environment, cluster: cluster)
      end

      it 'expires the environments path for the group cluster' do
        expect_next_instance_of(Gitlab::EtagCaching::Store) do |store|
          expect(store).to receive(:touch)
            .with(::Gitlab::Routing.url_helpers.project_environments_path(project, format: :json))
            .and_call_original

          expect(store).to receive(:touch)
            .with(::Gitlab::Routing.url_helpers.environments_admin_cluster_path(cluster))
            .and_call_original
        end

        subject
      end
    end
  end

  describe '#rollout_status' do
    let!(:cluster) { create(:cluster, :project, :provided_by_user, projects: [project]) }
    let!(:environment) { create(:environment, project: project) }
    let!(:deployment) { create(:deployment, :success, environment: environment, project: project) }

    subject { environment.rollout_status }

    context 'environment does not have a deployment board available' do
      before do
        allow(environment).to receive(:has_terminals?).and_return(false)
      end

      it { is_expected.to be_nil }
    end

    context 'cached rollout status is present' do
      let(:pods) { %w(pod1 pod2) }
      let(:deployments) { %w(deployment1 deployment2) }

      before do
        stub_reactive_cache(environment, pods: pods, deployments: deployments)
      end

      it 'fetches the rollout status from the deployment platform' do
        expect(environment.deployment_platform).to receive(:rollout_status)
          .with(environment, pods: pods, deployments: deployments)
          .and_return(:mock_rollout_status)

        is_expected.to eq(:mock_rollout_status)
      end
    end

    context 'cached rollout status is not present yet' do
      before do
        stub_reactive_cache(environment, nil)
      end

      it 'falls back to a loading status' do
        expect(::Gitlab::Kubernetes::RolloutStatus).to receive(:loading).and_return(:mock_loading_status)

        is_expected.to eq(:mock_loading_status)
      end
    end
  end
end
