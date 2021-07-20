# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Projects::ProtectDefaultBranchService do
  let(:service) { described_class.new(project) }
  let(:project) { create(:project) }

  describe '#protect_branch?' do
    context 'when project has security_policy_project' do
      it 'returns true' do
        allow(Security::OrchestrationPolicyConfiguration)
          .to receive(:exists?)
                .and_return(true)

        expect(service.protect_branch?).to eq(true)
      end
    end
  end

  describe '#push_access_level' do
    context 'when project has security_policy_project' do
      it 'returns NO_ACCESS access level' do
        allow(Security::OrchestrationPolicyConfiguration)
          .to receive(:exists?)
                .and_return(true)

        expect(service.push_access_level).to eq(Gitlab::Access::NO_ACCESS)
      end
    end

    context 'when project does not have security_policy_project' do
      it 'returns DEVELOPER access level' do
        allow(project.namespace)
          .to receive(:default_branch_protection)
                .and_return(Gitlab::Access::PROTECTION_DEV_CAN_PUSH)

        expect(service.push_access_level).to eq(Gitlab::Access::DEVELOPER)
      end
    end
  end

  describe '#merge_access_level' do
    context 'when project has security_policy_project' do
      it 'returns Maintainer access level' do
        allow(Security::OrchestrationPolicyConfiguration)
          .to receive(:exists?)
                .and_return(true)

        expect(service.merge_access_level).to eq(Gitlab::Access::MAINTAINER)
      end
    end

    context 'when project does not have security_policy_project' do
      it 'returns DEVELOPER access level' do
        allow(project.namespace)
          .to receive(:default_branch_protection)
                .and_return(Gitlab::Access::PROTECTION_DEV_CAN_MERGE)

        expect(service.merge_access_level).to eq(Gitlab::Access::DEVELOPER)
      end
    end
  end
end
