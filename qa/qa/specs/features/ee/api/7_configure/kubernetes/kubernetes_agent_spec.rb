# frozen_string_literal: true
require 'byebug'
require 'erb'
module QA
  RSpec.describe 'Configure' do
    describe 'Kubernetes Agent' do
      let!(:cluster) { Service::KubernetesCluster.new(provider_class: Service::ClusterProvider::K3s).create! }
      let(:manifest) do
        <<~YAML
          ---
          apiVersion: v1
          kind: Namespace
          metadata:
            name: game-ns
        YAML
      end

      let(:agent_token) do
        Resource::Clusters::AgentToken.fabricate_via_api!
      end

      # TODO: TEST THIS WITHOUT ADMIN
      before do
        Flow::Login.sign_in_as_admin
        cluster.create_secret(agent_token.secret, 'gitlab-agent-token')
        byebug
        uri = URI.parse(Runtime::Scenario.gitlab_address)
        gitlab_kas_host_and_port = "#{uri.host}:#{uri.port}"
        agent_manifest_template_path = Pathname
                                .new(__dir__)
                                .join('../../../../../../fixtures/kubernetes_agent/agent-manifest.yaml.erb')
        agent_manifest_template = File.read(agent_manifest_template_path)
        agent_manifest_yaml = ERB.new(agent_manifest_template).result(binding)
        cluster.apply_manifest(agent_manifest_yaml)
      end
      # before do
      #   Flow::Login.sign_in
      # end

      after do
        cluster.remove!
      end

      it 'can sync a config file between gitlab-kas and agentk', testcase: 'https://gitlab.com/gitlab-org/quality/testcases/-/issues/1106' do
        expect(agent_token).to be_a(QA::Resource::Clusters::AgentToken)
      end
    end
  end
end
