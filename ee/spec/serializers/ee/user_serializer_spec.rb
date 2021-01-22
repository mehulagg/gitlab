# frozen_string_literal: true

require 'spec_helper'

RSpec.describe UserSerializer do
  let_it_be(:user1) { create(:user) }
  let_it_be(:user2) { create(:user) }
  let_it_be(:merge_request) { create(:merge_request) }
  let_it_be(:project) { merge_request.project }
  let_it_be(:protected_branch) { create(:protected_branch, project: project, name: merge_request.target_branch) }
  let_it_be(:approval_project_rule) do
    create(:approval_project_rule, name: 'Project Rule', project: project, users: [user1], protected_branches: [protected_branch])
  end

  let(:serializer) { described_class.new(options.merge({ current_user: user1 })) }

  shared_examples 'user without applicable_approval_rules' do
    it 'returns a user without applicable_approval_rules' do
      serialized_user1, serialized_user2 = serializer.represent([user1, user2], project: project).as_json

      expect(serialized_user1.keys).not_to include('applicable_approval_rules')
      expect(serialized_user2.keys).not_to include('applicable_approval_rules')
    end
  end

  before do
    stub_licensed_features(multiple_approval_rules: true)
  end

  context 'with merge_request_iid' do
    let(:options) { { merge_request_iid: merge_request.iid } }

    context 'without approval_rules' do
      it_behaves_like 'user without applicable_approval_rules'
    end

    context 'with approval_rules' do
      let(:options) { super().merge(approval_rules: 'true') }

      context 'with merge request approval rules' do
        let!(:approval_merge_request_rule) do
          create(:approval_merge_request_rule, name: 'Merge Request Rule', merge_request: merge_request, users: [user1])
        end

        let!(:approval_code_owner_rule) do
          create(:code_owner_rule, name: 'Code Owner Rule', merge_request: merge_request, users: [user1])
        end

        it 'returns users with merge request approval rules' do
          serialized_user1, serialized_user2 = serializer.represent([user1, user2], project: project).as_json

          expect(serialized_user1).to include(
            'id' => user1.id,
            'applicable_approval_rules' => [
              { 'id' => approval_merge_request_rule.id, 'name' => 'Merge Request Rule', 'rule_type' => 'regular' },
              { 'id' => approval_code_owner_rule.id, 'name' => 'Code Owner Rule', 'rule_type' => 'code_owner' }
            ]
          )
          expect(serialized_user2).to include('id' => user2.id, 'applicable_approval_rules' => [])
        end
      end

      context 'without merge request approval rules' do
        it 'returns users with project approval rules' do
          serialized_user1, serialized_user2 = serializer.represent([user1, user2], project: project).as_json

          expect(serialized_user1).to include(
            'id' => user1.id,
            'applicable_approval_rules' => [
              { 'id' => approval_project_rule.id, 'name' => 'Project Rule', 'rule_type' => 'regular' }
            ]
          )
          expect(serialized_user2).to include('id' => user2.id, 'applicable_approval_rules' => [])
        end
      end
    end
  end

  context 'without merge_request_iid' do
    let(:options) { {} }

    context 'wsee/spec/serializers/ee/user_serializer_spec.rbthout approval_rules' do
      it_behaves_like 'user without applicable_approval_rules'
    end

    context 'with approval_rules' do
      let(:options) { super().merge(approval_rules: 'true') }

      it 'returns users with applicable_approval_rules' do
        serialized_user1, serialized_user2 = serializer.represent([user1, user2], project: project).as_json

        expect(serialized_user1).to include(
          'id' => user1.id,
          'applicable_approval_rules' => [
            { 'id' => approval_project_rule.id, 'name' => 'Project Rule', 'rule_type' => 'regular' }
          ]
        )
        expect(serialized_user2).to include('id' => user2.id, 'applicable_approval_rules' => [])
      end

      context 'with target_branch' do
        let(:options) { super().merge(target_branch: protected_branch.name) }

        it 'returns users with applicable_approval_rules' do
          serialized_user1, serialized_user2 = serializer.represent([user1, user2], project: project).as_json

          expect(serialized_user1).to include(
            'id' => user1.id,
            'applicable_approval_rules' => [
              { 'id' => approval_project_rule.id, 'name' => 'Project Rule', 'rule_type' => 'regular' }
            ]
          )
          expect(serialized_user2).to include('id' => user2.id, 'applicable_approval_rules' => [])
        end
      end

      context 'with unknown target_branch' do
        let(:options) { super().merge(target_branch: 'unknown_branch') }

        it 'returns users with applicable_approval_rules' do
          serialized_user1, serialized_user2 = serializer.represent([user1, user2], project: project).as_json

          expect(serialized_user1).to include('id' => user1.id, 'applicable_approval_rules' => [])
          expect(serialized_user2).to include('id' => user2.id, 'applicable_approval_rules' => [])
        end
      end
    end
  end
end
