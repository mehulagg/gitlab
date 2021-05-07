# frozen_string_literal: true

require 'spec_helper'

RSpec.describe GitlabSchema.types['UserMergeRequestInteraction'] do
  include GraphqlHelpers

  let_it_be(:user) { create(:user) }
  let_it_be(:current_user) { create(:user) }
  let_it_be(:project) { create(:project, :public, :repository) }
  let_it_be(:merge_request) { create(:merge_request, source_project: project) }

  let(:interaction) { ::Users::MergeRequestInteraction.new(user: user, merge_request: merge_request.reset) }

  it 'has the expected fields' do
    expected_fields = %w[
      applicable_approval_rules
    ]

    expect(described_class).to have_graphql_fields(*expected_fields).at_least
  end

  def resolve(field_name)
    resolve_field(field_name, interaction, current_user: current_user)
  end

  describe '#applicable_approval_rules' do
    subject { resolve(:applicable_approval_rules) }

    before do
      merge_request.clear_memoization(:approval_state)
    end

    context 'when there are no approval rules' do
      it { is_expected.to be_empty }
    end

    context 'when there are approval rules' do
      before do
        create(:approval_merge_request_rule, merge_request: merge_request)
        create(:code_owner_rule, merge_request: merge_request)
        create(:any_approver_rule, merge_request: merge_request)
      end

      context 'when the feature is not available' do
        it { is_expected.to be_empty }
      end

      context 'when the feature is available' do
        before do
          stub_licensed_features(merge_request_approvers: true)
        end

        it { is_expected.to be_empty }

        context 'when the user is associated with a rule' do
          let(:rule) { create(:code_owner_rule, merge_request: merge_request) }

          before do
            rule.users << user
          end

          it { is_expected.to contain_exactly(have_attributes(approval_rule: rule)) }
        end
      end
    end
  end
end
