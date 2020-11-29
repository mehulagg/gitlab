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
    let(:ingresses) { [] }
    let(:service) { create(:cluster_platform_kubernetes, :configured) }
    let!(:cluster) { create(:cluster, :project, enabled: true, platform_kubernetes: service) }
    let(:project) { cluster.project }
    let(:environment) { build(:environment, project: project, name: "env", slug: "env-000000") }
    let(:cache_data) { Hash(deployments: deployments, pods: pods, ingresses: ingresses) }

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
      end
    end

    context 'with no deployments but there are pods' do
      let(:deployments) do
        []
      end

      let(:pods) do
        [
          kube_pod(name: 'pod-1', environment_slug: environment.slug, project_slug: project.full_path_slug),
          kube_pod(name: 'pod-2', environment_slug: environment.slug, project_slug: project.full_path_slug)
        ]
      end

      it 'returns an empty array' do
        expect(rollout_status.instances).to eq([])
      end
    end

    context 'with valid deployments' do
      let(:matched_deployment) { kube_deployment(environment_slug: environment.slug, project_slug: project.full_path_slug, replicas: 2) }
      let(:unmatched_deployment) { kube_deployment }
      let(:matched_pod) { kube_pod(environment_slug: environment.slug, project_slug: project.full_path_slug, status: 'Pending') }
      let(:unmatched_pod) { kube_pod(environment_slug: environment.slug + '-test', project_slug: project.full_path_slug) }
      let(:deployments) { [matched_deployment, unmatched_deployment] }
      let(:pods) { [matched_pod, unmatched_pod] }

      it 'creates a matching RolloutStatus' do
        expect(rollout_status).to be_kind_of(::Gitlab::Kubernetes::RolloutStatus)
        expect(rollout_status.deployments.map(&:annotations)).to eq([
          { 'app.gitlab.com/app' => project.full_path_slug, 'app.gitlab.com/env' => 'env-000000' }
        ])
        expect(rollout_status.instances).to eq([{ pod_name: "kube-pod",
                                                 stable: true,
                                                 status: "pending",
                                                 tooltip: "kube-pod (Pending)",
                                                 track: "stable" },
                                                { pod_name: "Not provided",
                                                 stable: true,
                                                 status: "pending",
                                                 tooltip: "Not provided (Pending)",
                                                 track: "stable" }])
      end

      context 'with canary ingress' do
        let(:ingresses) { [kube_ingress(track: :canary)] }

        it 'has canary ingress' do
          expect(rollout_status).to be_canary_ingress_exists
          expect(rollout_status.canary_ingress.canary_weight).to eq(50)
        end
      end
    end

    context 'with empty list of deployments' do
      it 'creates a matching RolloutStatus' do
        expect(rollout_status).to be_kind_of(::Gitlab::Kubernetes::RolloutStatus)
        expect(rollout_status).to be_not_found
      end
    end

    context 'when the pod track does not match the deployment track' do
      let(:deployments) do
        [
          kube_deployment(name: 'deployment-a', environment_slug: environment.slug, project_slug: project.full_path_slug, replicas: 1, track: 'weekly')
        ]
      end

      let(:pods) do
        [
          kube_pod(name: 'pod-a-1', environment_slug: environment.slug, project_slug: project.full_path_slug, track: 'weekly'),
          kube_pod(name: 'pod-a-2', environment_slug: environment.slug, project_slug: project.full_path_slug, track: 'daily')
        ]
      end

      it 'does not return the pod' do
        expect(rollout_status.instances.map { |p| p[:pod_name] }).to eq(['pod-a-1'])
      end
    end

    context 'when the pod track is not stable' do
      let(:deployments) do
        [
          kube_deployment(name: 'deployment-a', environment_slug: environment.slug, project_slug: project.full_path_slug, replicas: 1, track: 'something')
        ]
      end

      let(:pods) do
        [
          kube_pod(name: 'pod-a-1', environment_slug: environment.slug, project_slug: project.full_path_slug, track: 'something')
        ]
      end

      it 'the pod is not stable' do
        expect(rollout_status.instances.map { |p| p.slice(:stable, :track) }).to eq([{ stable: false, track: 'something' }])
      end
    end

    context 'when the pod track is stable' do
      let(:deployments) do
        [
          kube_deployment(name: 'deployment-a', environment_slug: environment.slug, project_slug: project.full_path_slug, replicas: 1, track: 'stable')
        ]
      end

      let(:pods) do
        [
          kube_pod(name: 'pod-a-1', environment_slug: environment.slug, project_slug: project.full_path_slug, track: 'stable')
        ]
      end

      it 'the pod is stable' do
        expect(rollout_status.instances.map { |p| p.slice(:stable, :track) }).to eq([{ stable: true, track: 'stable' }])
      end
    end

    context 'when the pod track is not provided' do
      let(:deployments) do
        [
          kube_deployment(name: 'deployment-a', environment_slug: environment.slug, project_slug: project.full_path_slug, replicas: 1)
        ]
      end

      let(:pods) do
        [
          kube_pod(name: 'pod-a-1', environment_slug: environment.slug, project_slug: project.full_path_slug)
        ]
      end

      it 'the pod is stable' do
        expect(rollout_status.instances.map { |p| p.slice(:stable, :track) }).to eq([{ stable: true, track: 'stable' }])
      end
    end

    context 'when the number of matching pods does not match the number of replicas' do
      let(:deployments) do
        [
          kube_deployment(name: 'deployment-a', environment_slug: environment.slug, project_slug: project.full_path_slug, replicas: 3)
        ]
      end

      let(:pods) do
        [
          kube_pod(name: 'pod-a-1', environment_slug: environment.slug, project_slug: project.full_path_slug)
        ]
      end

      it 'returns a pending pod for each missing replica' do
        expect(rollout_status.instances.map { |p| p.slice(:pod_name, :status) }).to eq([
          { pod_name: 'pod-a-1', status: 'running' },
          { pod_name: 'Not provided', status: 'pending' },
          { pod_name: 'Not provided', status: 'pending' }
        ])
      end
    end

    context 'when pending pods are returned for missing replicas' do
      let(:deployments) do
        [
          kube_deployment(name: 'deployment-a', environment_slug: environment.slug, project_slug: project.full_path_slug, replicas: 2, track: 'canary'),
          kube_deployment(name: 'deployment-b', environment_slug: environment.slug, project_slug: project.full_path_slug, replicas: 2, track: 'stable')
        ]
      end

      let(:pods) do
        [
          kube_pod(name: 'pod-a-1', environment_slug: environment.slug, project_slug: project.full_path_slug, track: 'canary')
        ]
      end

      it 'returns the correct track for the pending pods' do
        expect(rollout_status.instances.map { |p| p.slice(:pod_name, :status, :track) }).to eq([
          { pod_name: 'pod-a-1', status: 'running', track: 'canary' },
          { pod_name: 'Not provided', status: 'pending', track: 'canary' },
          { pod_name: 'Not provided', status: 'pending', track: 'stable' },
          { pod_name: 'Not provided', status: 'pending', track: 'stable' }
        ])
      end
    end

    context 'when two deployments with the same track are missing instances' do
      let(:deployments) do
        [
          kube_deployment(name: 'deployment-a', environment_slug: environment.slug, project_slug: project.full_path_slug, replicas: 1, track: 'mytrack'),
          kube_deployment(name: 'deployment-b', environment_slug: environment.slug, project_slug: project.full_path_slug, replicas: 1, track: 'mytrack')
        ]
      end

      let(:pods) do
        []
      end

      it 'returns the correct number of pending pods' do
        expect(rollout_status.instances.map { |p| p.slice(:pod_name, :status, :track) }).to eq([
          { pod_name: 'Not provided', status: 'pending', track: 'mytrack' },
          { pod_name: 'Not provided', status: 'pending', track: 'mytrack' }
        ])
      end
    end

    context 'with multiple matching deployments' do
      let(:deployments) do
        [
          kube_deployment(name: 'deployment-a', environment_slug: environment.slug, project_slug: project.full_path_slug, replicas: 2),
          kube_deployment(name: 'deployment-b', environment_slug: environment.slug, project_slug: project.full_path_slug, replicas: 2)
        ]
      end

      let(:pods) do
        [
          kube_pod(name: 'pod-a-1', environment_slug: environment.slug, project_slug: project.full_path_slug),
          kube_pod(name: 'pod-a-2', environment_slug: environment.slug, project_slug: project.full_path_slug),
          kube_pod(name: 'pod-b-1', environment_slug: environment.slug, project_slug: project.full_path_slug),
          kube_pod(name: 'pod-b-2', environment_slug: environment.slug, project_slug: project.full_path_slug)
        ]
      end

      it 'returns each pod once' do
        expect(rollout_status.instances.map { |p| p[:pod_name] }).to eq(['pod-a-1', 'pod-a-2', 'pod-b-1', 'pod-b-2'])
      end
    end
  end

  describe '#calculate_reactive_cache_for' do
    let(:cluster) { create(:cluster, :project, platform_kubernetes: service) }
    let(:service) { create(:cluster_platform_kubernetes, :configured) }
    let(:namespace) { 'project-namespace' }
    let(:environment) { instance_double(Environment, deployment_namespace: namespace, project: cluster.project) }
    let(:expected_pod_cached_data) do
      kube_pod.tap { |kp| kp['metadata'].delete('namespace') }
    end

    subject { service.calculate_reactive_cache_for(environment) }

    context 'when kubernetes responds with valid deployments' do
      before do
        stub_kubeclient_pods(namespace)
        stub_kubeclient_deployments(namespace)
        stub_kubeclient_ingresses(namespace)
      end

      shared_examples 'successful deployment request' do
        it { is_expected.to include(pods: [expected_pod_cached_data], deployments: [kube_deployment], ingresses: [kube_ingress]) }
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

      context 'when canary_ingress_weight_control feature flag is disabled' do
        before do
          stub_feature_flags(canary_ingress_weight_control: false)
        end

        it 'does not fetch ingress data from kubernetes' do
          expect(subject[:ingresses]).to be_empty
        end
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
        stub_kubeclient_ingresses(namespace, status: 404)
      end

      it { is_expected.to include(deployments: [], ingresses: []) }
    end
  end

  describe '#ingresses' do
    subject { service.ingresses(namespace) }

    let(:service) { create(:cluster_platform_kubernetes, :configured) }
    let(:namespace) { 'project-namespace' }

    context 'when there is an ingress in the namespace' do
      before do
        stub_kubeclient_ingresses(namespace)
      end

      it 'returns an ingress' do
        expect(subject.count).to eq(1)
        expect(subject.first).to be_kind_of(::Gitlab::Kubernetes::Ingress)
        expect(subject.first.name).to eq('production-auto-deploy')
      end
    end

    context 'when there are no ingresss in the namespace' do
      before do
        allow(service.kubeclient).to receive(:get_ingresses) { raise Kubeclient::ResourceNotFoundError.new(404, 'Not found', nil) }
      end

      it 'returns nothing' do
        is_expected.to be_empty
      end
    end
  end

  describe '#patch_ingress' do
    subject { service.patch_ingress(namespace, ingress, data) }

    let(:service) { create(:cluster_platform_kubernetes, :configured) }
    let(:namespace) { 'project-namespace' }
    let(:ingress) { Gitlab::Kubernetes::Ingress.new(kube_ingress) }
    let(:data) { { metadata: { annotations: { name: 'test' } } } }

    context 'when there is an ingress in the namespace' do
      before do
        stub_kubeclient_ingresses(namespace, method: :patch, resource_path: "/#{ingress.name}")
      end

      it 'returns an ingress' do
        expect(subject[:items][0][:metadata][:name]).to eq('production-auto-deploy')
      end
    end

    context 'when there are no ingresss in the namespace' do
      before do
        allow(service.kubeclient).to receive(:patch_ingress) { raise Kubeclient::ResourceNotFoundError.new(404, 'Not found', nil) }
      end

      it 'raises an error' do
        expect { subject }.to raise_error(Kubeclient::ResourceNotFoundError)
      end
    end
  end
end
