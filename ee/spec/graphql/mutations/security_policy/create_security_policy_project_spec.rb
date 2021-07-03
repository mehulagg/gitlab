# frozen_string_literal: true
require 'spec_helper'

RSpec.describe Mutations::SecurityPolicy::CreateSecurityPolicyProject do
  let(:mutation) { described_class.new(object: nil, context: { current_user: user }, field: nil) }

  describe '#resolve' do
    let_it_be(:user) { create(:user) }
    let_it_be(:project) { create(:project, namespace: user.namespace) }

    subject { mutation.resolve(project_path: project.full_path) }

    context 'when feature is enabled and permission is set for user' do
      before do
        project.add_maintainer(user)

        stub_licensed_features(security_orchestration_policies: true)
        stub_feature_flags(security_orchestration_policies_configuration: true)
      end

      it 'returns project' do
        result = subject

        expect(result[:errors]).to be_empty
        expect(result[:project]).to eq(Project.last)
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
