# frozen_string_literal: true

require 'spec_helper'

RSpec.describe PolicyHelper do
  let(:project) { create(:project, :repository, :public) }
  let(:environment) { create(:environment, project: project) }

  let(:policy) do
    Gitlab::Kubernetes::CiliumNetworkPolicy.new(
      name: 'policy',
      namespace: 'another',
      selector: { matchLabels: { role: 'db' } },
      ingress: [{ from: [{ namespaceSelector: { matchLabels: { project: 'myproject' } } }] }]
    )
  end

  let(:base_data) do
    {
      network_policies_endpoint: kind_of(String),
      configure_agent_help_path: kind_of(String),
      create_agent_help_path: kind_of(String),
      environments_endpoint: kind_of(String),
      project_path: project.full_path,
      threat_monitoring_path: kind_of(String)
    }
  end

  describe '#policy_details' do
    context 'when a new policy is being created' do
      subject { helper.policy_details(project) }

      it 'returns expected policy data' do
        expect(subject).to match(base_data)
      end
    end

    context 'when an existing policy is being edited' do
      subject { helper.policy_details(project, policy, environment) }

      it 'returns expected policy data' do
        expect(subject).to match(
          base_data.merge(
            policy: policy.to_json,
            environment_id: environment.id
          )
        )
      end
    end

    context 'when no environment is passed in' do
      subject { helper.policy_details(project, policy) }

      it 'returns expected policy data' do
        expect(subject).to match(base_data)
      end
    end
  end
end
