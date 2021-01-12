# frozen_string_literal: true

require_relative '../../../../tooling/lib/tooling/kubernetes_client'

RSpec.describe Tooling::KubernetesClient do
  let(:namespace) { 'review-apps' }
  let(:release_name) { 'my-release' }
  let(:pod_for_release) { "pod-my-release-abcd" }
  let(:raw_resource_names_str) { "NAME\nfoo\n#{pod_for_release}\nbar" }
  let(:raw_resource_names) { raw_resource_names_str.lines.map(&:strip) }

  subject { described_class.new(namespace: namespace) }

  describe 'RESOURCE_LIST' do
    it 'returns the correct list of resources separated by commas' do
      expect(described_class::RESOURCE_LIST).to eq('ingress,svc,pdb,hpa,deploy,statefulset,job,pod,secret,configmap,pvc,secret,clusterrole,clusterrolebinding,role,rolebinding,sa,crd')
    end
  end

  describe '#cleanup_by_release' do
    before do
      allow(subject).to receive(:raw_resource_names).and_return(raw_resource_names)
    end

    it 'raises an error if the Kubernetes command fails' do
      expect(Gitlab::Popen).to receive(:popen_with_detail)
        .with(["kubectl delete #{described_class::RESOURCE_LIST} " +
          %(--namespace "#{namespace}" --now --ignore-not-found --include-uninitialized --wait=true -l release="#{release_name}")])
        .and_return(Gitlab::Popen::Result.new([], '', '', double(success?: false)))

      expect { subject.cleanup_by_release(release_name: release_name) }.to raise_error(described_class::CommandFailedError)
    end

    it 'calls kubectl with the correct arguments' do
      expect(Gitlab::Popen).to receive(:popen_with_detail)
        .with(["kubectl delete #{described_class::RESOURCE_LIST} " +
          %(--namespace "#{namespace}" --now --ignore-not-found --include-uninitialized --wait=true -l release="#{release_name}")])
        .and_return(Gitlab::Popen::Result.new([], '', '', double(success?: true)))

      expect(Gitlab::Popen).to receive(:popen_with_detail)
        .with([%(kubectl delete --namespace "#{namespace}" --ignore-not-found #{pod_for_release})])
        .and_return(Gitlab::Popen::Result.new([], '', '', double(success?: true)))

      # We're not verifying the output here, just silencing it
      expect { subject.cleanup_by_release(release_name: release_name) }.to output.to_stdout
    end

    context 'with multiple releases' do
      let(:release_name) { %w[my-release my-release-2] }

      it 'calls kubectl with the correct arguments' do
        expect(Gitlab::Popen).to receive(:popen_with_detail)
          .with(["kubectl delete #{described_class::RESOURCE_LIST} " +
            %(--namespace "#{namespace}" --now --ignore-not-found --include-uninitialized --wait=true -l 'release in (#{release_name.join(', ')})')])
          .and_return(Gitlab::Popen::Result.new([], '', '', double(success?: true)))

        expect(Gitlab::Popen).to receive(:popen_with_detail)
         .with([%(kubectl delete --namespace "#{namespace}" --ignore-not-found #{pod_for_release})])
         .and_return(Gitlab::Popen::Result.new([], '', '', double(success?: true)))

        # We're not verifying the output here, just silencing it
        expect { subject.cleanup_by_release(release_name: release_name) }.to output.to_stdout
      end
    end

    context 'with `wait: false`' do
      it 'calls kubectl with the correct arguments' do
        expect(Gitlab::Popen).to receive(:popen_with_detail)
          .with(["kubectl delete #{described_class::RESOURCE_LIST} " +
            %(--namespace "#{namespace}" --now --ignore-not-found --include-uninitialized --wait=false -l release="#{release_name}")])
          .and_return(Gitlab::Popen::Result.new([], '', '', double(success?: true)))

        expect(Gitlab::Popen).to receive(:popen_with_detail)
          .with([%(kubectl delete --namespace "#{namespace}" --ignore-not-found #{pod_for_release})])
          .and_return(Gitlab::Popen::Result.new([], '', '', double(success?: true)))

        # We're not verifying the output here, just silencing it
        expect { subject.cleanup_by_release(release_name: release_name, wait: false) }.to output.to_stdout
      end
    end
  end

  describe '#cleanup_by_created_at' do
    let(:two_days_ago) { Time.now - 3600 * 24 * 2 }
    let(:resource_type) { 'pvc' }

    before do
      allow(subject).to receive(:resource_names_created_before).with(resource_type: resource_type, created_before: two_days_ago).and_return([pod_for_release])
    end

    it 'raises an error if the Kubernetes command fails' do
      expect(Gitlab::Popen).to receive(:popen_with_detail)
        .with(["kubectl delete #{resource_type} " +
          %(--namespace "#{namespace}" --now --ignore-not-found --include-uninitialized --wait=true #{pod_for_release})])
        .and_return(Gitlab::Popen::Result.new([], '', '', double(success?: false)))

      expect { subject.cleanup_by_created_at(resource_type: resource_type, created_before: two_days_ago) }.to raise_error(described_class::CommandFailedError)
    end

    it 'calls kubectl with the correct arguments' do
      expect(Gitlab::Popen).to receive(:popen_with_detail)
        .with(["kubectl delete #{resource_type} " +
          %(--namespace "#{namespace}" --now --ignore-not-found --include-uninitialized --wait=true #{pod_for_release})])
        .and_return(Gitlab::Popen::Result.new([], '', '', double(success?: true)))

      # We're not verifying the output here, just silencing it
      expect { subject.cleanup_by_created_at(resource_type: resource_type, created_before: two_days_ago) }.to output.to_stdout
    end

    context 'with multiple resource names' do
      let(:resource_names) { %w[my-release my-release-2] }

      before do
        allow(subject).to receive(:resource_names_created_before).with(resource_type: resource_type, created_before: two_days_ago).and_return(resource_names)
      end

      it 'calls kubectl with the correct arguments' do
        expect(Gitlab::Popen).to receive(:popen_with_detail)
          .with(["kubectl delete #{resource_type} " +
            %(--namespace "#{namespace}" --now --ignore-not-found --include-uninitialized --wait=true #{resource_names.join(' ')})])
          .and_return(Gitlab::Popen::Result.new([], '', '', double(success?: true)))

        # We're not verifying the output here, just silencing it
        expect { subject.cleanup_by_created_at(resource_type: resource_type, created_before: two_days_ago) }.to output.to_stdout
      end
    end

    context 'with `wait: false`' do
      it 'calls kubectl with the correct arguments' do
        expect(Gitlab::Popen).to receive(:popen_with_detail)
          .with(["kubectl delete #{resource_type} " +
            %(--namespace "#{namespace}" --now --ignore-not-found --include-uninitialized --wait=false #{pod_for_release})])
          .and_return(Gitlab::Popen::Result.new([], '', '', double(success?: true)))

        # We're not verifying the output here, just silencing it
        expect { subject.cleanup_by_created_at(resource_type: resource_type, created_before: two_days_ago, wait: false) }.to output.to_stdout
      end
    end

    context 'with no resource_type given' do
      let(:resource_type) { nil }

      it 'calls kubectl with the correct arguments' do
        expect(Gitlab::Popen).to receive(:popen_with_detail)
          .with(["kubectl delete " +
            %(--namespace "#{namespace}" --now --ignore-not-found --include-uninitialized --wait=true #{pod_for_release})])
          .and_return(Gitlab::Popen::Result.new([], '', '', double(success?: true)))

        # We're not verifying the output here, just silencing it
        expect { subject.cleanup_by_created_at(resource_type: resource_type, created_before: two_days_ago) }.to output.to_stdout
      end
    end
  end

  describe '#raw_resource_names' do
    it 'calls kubectl to retrieve the resource names' do
      expect(Gitlab::Popen).to receive(:popen_with_detail)
        .with(["kubectl get #{described_class::RESOURCE_LIST} " +
          %(--namespace "#{namespace}" -o name)])
        .and_return(Gitlab::Popen::Result.new([], raw_resource_names_str, '', double(success?: true)))

      expect(subject.__send__(:raw_resource_names)).to eq(raw_resource_names)
    end
  end

  describe '#resource_names_created_before' do
    let(:three_days_ago) { Time.now - 3600 * 24 * 3 }
    let(:two_days_ago) { Time.now - 3600 * 24 * 2 }
    let(:pvc_created_three_days_ago) { 'pvc-created-three-days-ago' }
    let(:resource_type) { 'pvc' }
    let(:resource_names) do
      {
        items: [
          {
            "apiVersion": "v1",
            "kind": "PersistentVolumeClaim",
            "metadata": {
                "creationTimestamp": three_days_ago,
                "name": pvc_created_three_days_ago
            }
          },
          {
            "apiVersion": "v1",
            "kind": "PersistentVolumeClaim",
            "metadata": {
                "creationTimestamp": Time.now,
                "name": 'another-pvc'
            }
          }
        ]
      }
    end

    it 'calls kubectl to retrieve the resource names' do
      expect(Gitlab::Popen).to receive(:popen_with_detail)
        .with(["kubectl get #{resource_type} " +
          %(--namespace "#{namespace}" ) +
          "--sort-by='{.metadata.creationTimestamp}' -o json"])
        .and_return(Gitlab::Popen::Result.new([], resource_names.to_json, '', double(success?: true)))

      expect(subject.__send__(:resource_names_created_before, resource_type: resource_type, created_before: two_days_ago)).to contain_exactly(pvc_created_three_days_ago)
    end

    context 'with no resource_type given' do
      it 'calls kubectl to retrieve the resource names' do
        expect(Gitlab::Popen).to receive(:popen_with_detail)
          .with(["kubectl get " +
            %(--namespace "#{namespace}" ) +
            "--sort-by='{.metadata.creationTimestamp}' -o json"])
          .and_return(Gitlab::Popen::Result.new([], resource_names.to_json, '', double(success?: true)))

        expect(subject.__send__(:resource_names_created_before, resource_type: nil, created_before: two_days_ago)).to contain_exactly(pvc_created_three_days_ago)
      end
    end
  end
end
