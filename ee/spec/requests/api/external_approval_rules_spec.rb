# frozen_string_literal: true

require 'spec_helper'

RSpec.describe ::API::ExternalApprovalRules do
  using RSpec::Parameterized::TableSyntax

  let_it_be(:project) { create(:project) }
  let_it_be(:rule) { create(:external_approval_rule, project: project, name: 'Rule 2', external_url: 'https://rule2.example') }
  let(:collection_url) { "/projects/#{project.id}/external_approval_rules" }
  let(:single_object_url) { "/projects/#{project.id}/external_approval_rules/#{rule.id}" }

  describe 'DELETE projects/:id/external_approval_rules/:rule_id' do
    before do
      stub_licensed_features(compliance_approval_gates: true)
    end

    it 'deletes the specified rule' do
      expect do
        delete api(single_object_url, project.owner)
      end.to change { ApprovalRules::ExternalApprovalRule.count }.by(-1)
    end

    context 'when feature is disabled, unlicensed or user has permission' do
      where(:licensed, :flag, :project_owner, :status) do
        false | false | false | :not_found
        false | false | true  | :unauthorized
        false | true  | true  | :unauthorized
        false | true  | false | :not_found
        true  | false | false | :not_found
        true  | false | true  | :unauthorized
        true  | true  | false | :not_found
        true  | true  | true  | :success
      end

      with_them do
        before do
          stub_feature_flags(ff_compliance_approval_gates: flag)
          stub_licensed_features(compliance_approval_gates: licensed)
        end

        it 'returns the correct status code' do
          delete api(single_object_url, (project_owner ? project.owner : build(:user)))

          expect(response).to have_gitlab_http_status(status)
        end
      end
    end
  end

  describe 'GET projects/:id/external_approval_rules' do
    let_it_be(:rule) { create(:external_approval_rule, project: project, name: 'Rule 1', external_url: "http://rule1.example") }
    let_it_be(:protected_branches) { create_list(:protected_branch, 3, project: project) }

    before_all do
      create(:external_approval_rule) # Creating an orphaned rule to make sure project scoping works as expected
    end

    before do
      stub_licensed_features(compliance_approval_gates: true)
    end

    it 'responds with expected JSON', :aggregate_failures do
      get api(collection_url, project.owner)

      expect(json_response.size).to eq(2)
      expect(json_response.map { |r| r['name'] }).to contain_exactly('Rule 1', 'Rule 2')
      expect(json_response.map { |r| r['external_url'] }).to contain_exactly('http://rule1.example', 'https://rule2.example')
    end

    it 'paginates correctly' do
      get api(collection_url, project.owner), params: { per_page: 1 }

      expect_paginated_array_response([1])
    end

    context 'when feature is disabled, unlicensed or user has permission' do
      where(:licensed, :flag, :project_owner, :status) do
        false | false | false | :not_found
        false | false | true  | :unauthorized
        false | true  | true  | :unauthorized
        false | true  | false | :not_found
        true  | false | false | :not_found
        true  | false | true  | :unauthorized
        true  | true  | false | :not_found
        true  | true  | true  | :success
      end

      with_them do
        before do
          stub_feature_flags(ff_compliance_approval_gates: flag)
          stub_licensed_features(compliance_approval_gates: licensed)
        end

        it 'returns the correct status code' do
          get api(collection_url, (project_owner ? project.owner : build(:user)))

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
        expect { subject }.to change { ApprovalRules::ExternalApprovalRule.count }.by(1)
      end

      context 'with protected branches' do
        let_it_be(:protected_branch) { create(:protected_branch, project: project) }
        let(:params) do
          { name: 'New rule', external_url: 'https://gitlab.com/test/example.json', protected_branch_ids: protected_branch.id }
        end

        subject do
          post api("/projects/#{project.id}/external_approval_rules", project.owner), params: params
        end

        it 'returns expected status code' do
          subject

          expect(response).to have_gitlab_http_status(:created)
        end

        it 'creates protected branch records' do
          subject

          expect(ApprovalRules::ExternalApprovalRule.last.protected_branches.count).to eq 1
        end

        it 'responds with expected JSON' do
          subject

          expect(json_response['id']).not_to be_nil
          expect(json_response['name']).to eq('New rule')
          expect(json_response['external_url']).to eq('https://gitlab.com/test/example.json')
          expect(json_response['protected_branches'].size).to eq(1)
        end
      end
    end

    context 'when feature is disabled, unlicensed or user has permission' do
      where(:licensed, :flag, :project_owner, :status) do
        false | false | false | :not_found
        false | false | true  | :unauthorized
        false | true  | true  | :unauthorized
        false | true  | false | :not_found
        true  | false | false | :not_found
        true  | false | true  | :unauthorized
        true  | true  | false | :not_found
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

  describe 'PUT projects/:id/external_approval_rules/:rule_id' do
    let(:params) { { external_url: 'http://newvalue.com', name: 'new name' } }

    context 'successfully updating external approval rule' do
      before do
        stub_feature_flags(ff_compliance_approval_gates: true)
        stub_licensed_features(compliance_approval_gates: true)
      end

      subject do
        put api(single_object_url, project.owner), params: params
      end

      it 'updates an approval rule' do
        expect { subject }.to change { rule.reload.external_url }.to eq('http://newvalue.com')
      end

      it 'responds with correct http status' do
        subject

        expect(response).to have_gitlab_http_status(:success)
      end

      context 'with protected branches' do
        let_it_be(:protected_branch) { create(:protected_branch, project: project) }
        let(:params) do
          { name: 'New rule', external_url: 'https://gitlab.com/test/example.json', protected_branch_ids: protected_branch.id }
        end

        subject do
          put api(single_object_url, project.owner), params: params
        end

        it 'returns expected status code' do
          subject

          expect(response).to have_gitlab_http_status(:success)
        end

        it 'creates protected branch records' do
          expect { subject }.to change { ApprovalRules::ExternalApprovalRule.last.protected_branches.count }.by(1)
        end

        it 'responds with expected JSON', :aggregate_failures do
          subject

          expect(json_response['id']).not_to be_nil
          expect(json_response['name']).to eq('New rule')
          expect(json_response['external_url']).to eq('https://gitlab.com/test/example.json')
          expect(json_response['protected_branches'].size).to eq(1)
        end
      end
    end

    context 'when feature is disabled, unlicensed or user has permission' do
      where(:licensed, :flag, :project_owner, :status) do
        false | false | false | :not_found
        false | false | true  | :unauthorized
        false | true  | true  | :unauthorized
        false | true  | false | :not_found
        true  | false | false | :not_found
        true  | false | true  | :unauthorized
        true  | true  | false | :not_found
        true  | true  | true  | :success
      end

      with_them do
        before do
          stub_feature_flags(ff_compliance_approval_gates: flag)
          stub_licensed_features(compliance_approval_gates: licensed)
        end

        it 'returns the correct status code' do
          put api(single_object_url, (project_owner ? project.owner : build(:user))), params: attributes_for(:external_approval_rule)

          expect(response).to have_gitlab_http_status(status)
        end
      end
    end
  end
end
