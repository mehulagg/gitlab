# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Clusters::Platforms::Kubernetes do
  include KubernetesHelpers
  include ReactiveCachingHelpers

  shared_examples 'resource not found error' do |message|
    it 'raises error' do
      result = subject

      expect(result[:error]).to eq(message)
      expect(result[:status]).to eq(:error)
    end
  end

  shared_examples 'kubernetes API error' do |error_code|
    it 'raises error' do
      result = subject

      expect(result[:error]).to eq("Kubernetes API returned status code: #{error_code}")
      expect(result[:status]).to eq(:error)
    end
  end

  describe '#rollout_status' do
    let(:deployments) { [] }
    let(:pods) { [] }
    let(:service) { create(:cluster_platform_kubernetes, :configured) }
    let!(:cluster) { create(:cluster, :project, enabled: true, platform_kubernetes: service) }
    let(:project) { cluster.project }
    let(:environment) { build(:environment, project: project, name: "env", slug: "env-000000") }
    let(:cache_data) { Hash(deployments: deployments, pods: pods) }

    subject(:rollout_status) { service.rollout_status(environment, cache_data) }

    context 'legacy deployments based on app label' do
      let(:legacy_deployment) do
        kube_deployment(name: 'legacy-deployment').tap do |deployment|
          deployment['metadata']['annotations'].delete('app.gitlab.com/env')
          deployment['metadata']['annotations'].delete('app.gitlab.com/app')
          deployment['metadata']['labels']['app'] = environment.slug
        end
      end

      let(:legacy_pod) do
        kube_pod(name: 'legacy-pod').tap do |pod|
          pod['metadata']['annotations'].delete('app.gitlab.com/env')
          pod['metadata']['annotations'].delete('app.gitlab.com/app')
          pod['metadata']['labels']['app'] = environment.slug
        end
      end

      context 'only legacy deployments' do
        let(:deployments) { [legacy_deployment] }
        let(:pods) { [legacy_pod] }

        it 'contains nothing' do
          expect(rollout_status).to be_kind_of(::Gitlab::Kubernetes::RolloutStatus)

          expect(rollout_status.deployments).to eq([])
        end

        it 'has the has_legacy_app_label flag' do
          expect(rollout_status).to be_has_legacy_app_label
        end
      end

      context 'deployment with no pods' do
        let(:deployment) { kube_deployment(name: 'some-deployment', environment_slug: environment.slug, project_slug: project.full_path_slug) }
        let(:deployments) { [deployment] }
        let(:pods) { [] }

        it 'returns a valid status with matching deployments' do
          expect(rollout_status).to be_kind_of(::Gitlab::Kubernetes::RolloutStatus)
          expect(rollout_status.deployments.map(&:name)).to contain_exactly('some-deployment')
        end
      end

      context 'new deployment based on annotations' do
        let(:matched_deployment) { kube_deployment(name: 'matched-deployment', environment_slug: environment.slug, project_slug: project.full_path_slug) }
        let(:matched_pod) { kube_pod(environment_slug: environment.slug, project_slug: project.full_path_slug) }
        let(:deployments) { [matched_deployment, legacy_deployment] }
        let(:pods) { [matched_pod, legacy_pod] }

        it 'contains only matching deployments' do
          expect(rollout_status).to be_kind_of(::Gitlab::Kubernetes::RolloutStatus)

          expect(rollout_status.deployments.map(&:name)).to contain_exactly('matched-deployment')
        end

        it 'does have the has_legacy_app_label flag' do
          expect(rollout_status).to be_has_legacy_app_label
        end
      end

      context 'deployment with app label not matching the environment' do
        let(:other_deployment) do
          kube_deployment(name: 'other-deployment').tap do |deployment|
            deployment['metadata']['annotations'].delete('app.gitlab.com/env')
            deployment['metadata']['annotations'].delete('app.gitlab.com/app')
            deployment['metadata']['labels']['app'] = 'helm-app-label'
          end
        end

        let(:other_pod) do
          kube_pod(name: 'other-pod').tap do |pod|
            pod['metadata']['annotations'].delete('app.gitlab.com/env')
            pod['metadata']['annotations'].delete('app.gitlab.com/app')
            pod['metadata']['labels']['app'] = environment.slug
          end
        end

        let(:deployments) { [other_deployment] }
        let(:pods) { [other_pod] }

        it 'does not have the has_legacy_app_label flag' do
          expect(rollout_status).not_to be_has_legacy_app_label
        end
      end
    end

    context 'with valid deployments' do
      let(:matched_deployment) { kube_deployment(environment_slug: environment.slug, project_slug: project.full_path_slug) }
      let(:unmatched_deployment) { kube_deployment }
      let(:matched_pod) { kube_pod(environment_slug: environment.slug, project_slug: project.full_path_slug) }
      let(:unmatched_pod) { kube_pod(environment_slug: environment.slug, project_slug: project.full_path_slug, status: 'Pending') }
      let(:deployments) { [matched_deployment, unmatched_deployment] }
      let(:pods) { [matched_pod, unmatched_pod] }

      it 'creates a matching RolloutStatus' do
        expect(rollout_status).to be_kind_of(::Gitlab::Kubernetes::RolloutStatus)
        expect(rollout_status.deployments.map(&:annotations)).to eq([
          { 'app.gitlab.com/app' => project.full_path_slug, 'app.gitlab.com/env' => 'env-000000' }
        ])
      end
    end

    context 'with empty list of deployments' do
      it 'creates a matching RolloutStatus' do
        expect(rollout_status).to be_kind_of(::Gitlab::Kubernetes::RolloutStatus)
        expect(rollout_status).to be_not_found
      end
    end
  end

  describe '#calculate_reactive_cache_for' do
    let(:cluster) { create(:cluster, :project, platform_kubernetes: service) }
    let(:service) { create(:cluster_platform_kubernetes, :configured) }
    let(:namespace) { 'project-namespace' }
    let(:environment) { instance_double(Environment, deployment_namespace: namespace) }
    let(:expected_pod_cached_data) do
      kube_pod.tap { |kp| kp['metadata'].delete('namespace') }
    end

    subject { service.calculate_reactive_cache_for(environment) }

    context 'when kubernetes responds with valid deployments' do
      before do
        stub_kubeclient_pods(namespace)
        stub_kubeclient_deployments(namespace)
      end

      shared_examples 'successful deployment request' do
        it { is_expected.to include(pods: [expected_pod_cached_data], deployments: [kube_deployment]) }
      end

      context 'on a project level cluster' do
        let(:cluster) { create(:cluster, :project, platform_kubernetes: service) }

        include_examples 'successful deployment request'
      end

      context 'on a group level cluster' do
        let(:cluster) { create(:cluster, :group, platform_kubernetes: service) }

        include_examples 'successful deployment request'
      end

      context 'on an instance level cluster' do
        let(:cluster) { create(:cluster, :instance, platform_kubernetes: service) }

        include_examples 'successful deployment request'
      end
    end

    context 'when kubernetes responds with 500s' do
      before do
        stub_kubeclient_pods(namespace)
        stub_kubeclient_deployments(namespace, status: 500)
      end

      it { expect { subject }.to raise_error(::Kubeclient::HttpError) }
    end

    context 'when kubernetes responds with 404s' do
      before do
        stub_kubeclient_pods(namespace)
        stub_kubeclient_deployments(namespace, status: 404)
      end

      it { is_expected.to include(deployments: []) }
    end
  end
end
