# frozen_string_literal: true

require 'spec_helper'

RSpec.describe ::API::ExternalApprovalRules do
  using RSpec::Parameterized::TableSyntax

  let_it_be(:project) { create(:project) }

  describe 'GET projects/:id/external_approval_rules' do
    let_it_be(:protected_branches) { create_list(:protected_branch, 3, project: project) }

    context 'when feature is disabled, unlicensed or user has permission' do
      where(:licensed, :flag, :project_owner, :status) do
        false | false | false | :unauthorized
        false | false | true  | :unauthorized
        false | true  | true  | :unauthorized
        false | true  | false | :unauthorized
        true  | false | false | :unauthorized
        true  | false | true  | :unauthorized
        true  | true  | false | :unauthorized
        true  | true  | true  | :success
      end

      with_them do
        before do
          stub_feature_flags(ff_compliance_approval_gates: flag)
          stub_licensed_features(compliance_approval_gates: licensed)
        end

        it 'returns the correct status code' do
          get api("/projects/#{project.id}/external_approval_rules", (project_owner ? project.owner : build(:user)))

          expect(response).to have_gitlab_http_status(status)
        end
      end
    end
  end

  describe 'POST projects/:id/external_approval_rules' do
    context 'successfully creating new external approval rule' do
      before do
        stub_feature_flags(ff_compliance_approval_gates: true)
        stub_licensed_features(compliance_approval_gates: true)
      end

      subject do
        post api("/projects/#{project.id}/external_approval_rules", project.owner), params: attributes_for(:external_approval_rule)
      end

      it 'creates a new external approval rule' do
        expect { subject }.to change { ExternalApprovalRule.count }.by(1)
      end

      context 'with protected branches' do
        let_it_be(:protected_branch) { create(:protected_branch, project: project) }
        let(:params) do
          { name: 'New rule', external_url: 'https://gitlab.com/test/example.json', protected_branch_ids: protected_branch.id }
        end

        subject do
          post api("/projects/#{project.id}/external_approval_rules", project.owner), params: params
        end

        it 'creates protected branch records' do
          subject

          expect(ExternalApprovalRule.last.protected_branches.count).to eq 1
        end
      end
    end

    context 'when feature is disabled, unlicensed or user has permission' do
      where(:licensed, :flag, :project_owner, :status) do
        false | false | false | :unauthorized
        false | false | true  | :unauthorized
        false | true  | true  | :unauthorized
        false | true  | false | :unauthorized
        true  | false | false | :unauthorized
        true  | false | true  | :unauthorized
        true  | true  | false | :unauthorized
        true  | true  | true  | :created
      end

      with_them do
        before do
          stub_feature_flags(ff_compliance_approval_gates: flag)
          stub_licensed_features(compliance_approval_gates: licensed)
        end

        it 'returns the correct status code' do
          post api("/projects/#{project.id}/external_approval_rules", (project_owner ? project.owner : build(:user))), params: attributes_for(:external_approval_rule)

          expect(response).to have_gitlab_http_status(status)
        end
      end
    end
  end
end
