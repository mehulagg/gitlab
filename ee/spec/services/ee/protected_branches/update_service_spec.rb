# frozen_string_literal: true

require 'spec_helper'

RSpec.describe ProtectedBranches::UpdateService do
  let(:branch_name) { 'feature' }
  let(:protected_branch) { create(:protected_branch, :no_one_can_push, name: branch_name) }
  let(:project) { protected_branch.project }
  let(:user) { project.owner }

  let(:params) do
    {
      name: branch_name,
      merge_access_levels_attributes: [{ access_level: Gitlab::Access::DEVELOPER }],
      push_access_levels_attributes: [{ access_level: Gitlab::Access::MAINTAINER }]
    }
  end

  describe '#execute' do
    subject(:service) { described_class.new(project, user, params) }

    it 'adds a security audit event entry' do
      expect { service.execute(protected_branch) }.to change(::AuditEvent, :count).by(1)
    end

    context 'with invalid params' do
      let(:params) do
        {
          name: branch_name,
          merge_access_levels_attributes: [{ access_level: Gitlab::Access::MAINTAINER }]
        }
      end

      it "doesn't add a security audit event entry" do
        expect { service.execute(protected_branch) }.not_to change(::AuditEvent, :count)
      end
    end
  end
end
