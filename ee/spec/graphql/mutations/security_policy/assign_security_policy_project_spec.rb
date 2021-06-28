# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Mutations::SecurityPolicy::AssignSecurityPolicyProject do
  let(:mutation) { described_class.new(object: nil, context: { current_user: user }, field: nil) }

  describe '#resolve' do
    let_it_be(:user) { create(:user) }
    let_it_be(:project) { create(:project, namespace: user.namespace) }
    let_it_be(:policy_project) { create(:project) }
    let_it_be(:policy_project_id) { GitlabSchema.id_from_object(policy_project) }

    subject { mutation.resolve(project_path: project.full_path, security_policy_project_id: policy_project_id) }

    context 'when feature is enabled and permission is set for user' do
      before do
        stub_licensed_features(security_orchestration_policies: true)
        stub_feature_flags(security_orchestration_policies_configuration: true)
      end

      it 'assigns the security policy project' do
        result = subject

        expect(result[:errors]).to be_empty
        expect(project.security_orchestration_policy_configuration).not_to be_nil
        expect(project.security_orchestration_policy_configuration.security_policy_management_project).to eq(policy_project)
      end
    end

    context 'when policy_project_id is invalid' do
      let_it_be(:policy_project_id) { 'invalid' }

      it 'raises exception' do
        expect { subject }.to raise_error(Gitlab::Graphql::Errors::ResourceNotAvailable)
      end
    end

    context 'when feature is disabled' do
      before do
        stub_licensed_features(security_orchestration_policies: true)
        stub_feature_flags(security_orchestration_policies_configuration: false)
      end

      it 'raises exception' do
        expect { subject }.to raise_error(Gitlab::Graphql::Errors::ResourceNotAvailable)
      end
    end

    context 'when permission is not enabled' do
      before do
        stub_licensed_features(security_orchestration_policies: false)
      end

      it 'raises exception' do
        expect { subject }.to raise_error(Gitlab::Graphql::Errors::ResourceNotAvailable)
      end
    end
  end
end
