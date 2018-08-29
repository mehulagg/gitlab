require 'rails_helper'

describe Gitlab::Kubernetes::Helm::InstallCommand do
  let(:files) { { 'ca.pem': 'some file content' } }
  let(:repository) { 'https://repository.example.com' }
  let(:rbac) { false }
  let(:version) { '1.2.3' }

  let(:install_command) do
    described_class.new(
      name: 'app-name',
      chart: 'chart-name',
      rbac: rbac,
      files: files,
      version: version,
      repository: repository
    )
  end

  subject { install_command }

  it_behaves_like 'helm commands' do
    let(:commands) do
      <<~EOS
      helm init --client-only >/dev/null
      helm repo add app-name https://repository.example.com
      helm install chart-name --name app-name --tls --tls-ca-cert /data/helm/app-name/config/ca.pem --tls-cert /data/helm/app-name/config/cert.pem --tls-key /data/helm/app-name/config/key.pem --version 1.2.3 --namespace gitlab-managed-apps -f /data/helm/app-name/config/values.yaml >/dev/null
      EOS
    end
  end

  context 'when rbac is true' do
    let(:rbac) { true }

    it_behaves_like 'helm commands' do
      let(:commands) do
        <<~EOS
        helm init --client-only >/dev/null
        helm repo add app-name https://repository.example.com
        helm install chart-name --name app-name --tls --tls-ca-cert /data/helm/app-name/config/ca.pem --tls-cert /data/helm/app-name/config/cert.pem --tls-key /data/helm/app-name/config/key.pem --version 1.2.3 --set rbac.create=true,rbac.enabled=true --namespace gitlab-managed-apps -f /data/helm/app-name/config/values.yaml >/dev/null
        EOS
      end
    end
  end

  context 'when there is no repository' do
    let(:repository) { nil }

    it_behaves_like 'helm commands' do
      let(:commands) do
        <<~EOS
         helm init --client-only >/dev/null
         helm install chart-name --name app-name --tls --tls-ca-cert /data/helm/app-name/config/ca.pem --tls-cert /data/helm/app-name/config/cert.pem --tls-key /data/helm/app-name/config/key.pem --version 1.2.3 --namespace gitlab-managed-apps -f /data/helm/app-name/config/values.yaml >/dev/null
        EOS
      end
    end
  end

  context 'when there is no ca.pem file' do
    let(:files) { { 'file.txt': 'some content' } }

    it_behaves_like 'helm commands' do
      let(:commands) do
        <<~EOS
         helm init --client-only >/dev/null
         helm repo add app-name https://repository.example.com
         helm install chart-name --name app-name --version 1.2.3 --namespace gitlab-managed-apps -f /data/helm/app-name/config/values.yaml >/dev/null
        EOS
      end
    end
  end

  context 'when there is no version' do
    let(:version) { nil }

    it_behaves_like 'helm commands' do
      let(:commands) do
        <<~EOS
         helm init --client-only >/dev/null
         helm repo add app-name https://repository.example.com
         helm install chart-name --name app-name --tls --tls-ca-cert /data/helm/app-name/config/ca.pem --tls-cert /data/helm/app-name/config/cert.pem --tls-key /data/helm/app-name/config/key.pem --namespace gitlab-managed-apps -f /data/helm/app-name/config/values.yaml >/dev/null
        EOS
      end
    end
  end

  describe '#rbac' do
    subject { install_command.rbac }

    context 'rbac is enabled' do
      let(:rbac) { true }

      it { is_expected.to be_truthy }
    end

    context 'rbac is not enabled' do
      let(:rbac) { false }

      it { is_expected.to be_falsey }
    end
  end

  describe '#pod_resource' do
    subject { install_command.pod_resource }

    context 'rbac is enabled' do
      let(:rbac) { true }

      it 'generates a pod that uses the tiller serviceAccountName' do
        expect(subject.spec.serviceAccountName).to eq('tiller')
      end
    end

    context 'rbac is not enabled' do
      let(:rbac) { false }

      it 'generates a pod that uses the default serviceAccountName' do
        expect(subject.spec.serviceAcccountName).to be_nil
      end
    end
  end

  describe '#create_resources' do
    let(:kubeclient) { double('kubeclient') } # strict double

    it 'does a no-op' do
      install_command.create_resources(kubeclient)
    end
  end

  describe '#config_map_resource' do
    let(:metadata) do
      {
        name: "values-content-configuration-app-name",
        namespace: 'gitlab-managed-apps',
        labels: { name: "values-content-configuration-app-name" }
      }
    end

    let(:resource) { ::Kubeclient::Resource.new(metadata: metadata, data: files) }

    subject { install_command.config_map_resource }

    it 'returns a KubeClient resource with config map content for the application' do
      is_expected.to eq(resource)
    end
  end
end
