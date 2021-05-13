# frozen_string_literal: true

require 'spec_helper'

RSpec.describe 'getting Incident Management escalation policies' do
  include GraphqlHelpers

  let_it_be(:current_user) { create(:user) }
  let_it_be(:project) { create(:project) }
  let_it_be(:schedule) { create(:incident_management_oncall_schedule, project: project) }

  let(:params) { {} }

  let(:fields) do
    <<~QUERY
      nodes {
        #{all_graphql_fields_for('EscalationPolicyType')}
      }
    QUERY
  end

  let(:query) do
    graphql_query_for(
      'project',
      { 'fullPath' => project.full_path },
      query_graphql_field('incidentManagementEscalationPolicies', {}, fields)
    )
  end

  let(:escalation_policies) { graphql_data.dig('project', 'incidentManagementEscalationPolicies', 'nodes') }

  before do
    stub_licensed_features(oncall_schedules: true, escalation_policies: true)
    stub_feature_flags(escalation_policies_mvc: project)
  end

  context 'without project permissions' do
    let(:user) { create(:user) }

    before do
      post_graphql(query, current_user: current_user)
    end

    it_behaves_like 'a working graphql query'

    it { expect(escalation_policies).to be_nil }
  end

  context 'with project permissions' do
    before do
      project.add_reporter(current_user)
    end

    context 'with unavailable feature' do
      before do
        stub_licensed_features(escalation_policies: false)
        post_graphql(query, current_user: current_user)
      end

      it_behaves_like 'a working graphql query'

      it { expect(escalation_policies).to be_empty }
    end

    context 'without escalation policies' do
      before do
        post_graphql(query, current_user: current_user)
      end

      it_behaves_like 'a working graphql query'

      it { expect(escalation_policies).to be_empty }
    end

    context 'with escalation policies' do
      let_it_be(:policy) { create(:incident_management_escalation_policy, project: project) }
      let_it_be(:second_policy) { create(:incident_management_escalation_policy, project: project) }

      let(:last_policy) { escalation_policies.last }

      before do
        post_graphql(query, current_user: current_user)
      end

      it_behaves_like 'a working graphql query'

      it 'returns the correct properties of the escalation policy' do
        expect(escalation_policies.size).to eq(2)
        expect(last_policy).to include(
          'id' => policy.to_global_id.to_s,
          'name' => policy.name,
          'description' => policy.description
        )
      end

      context 'requesting single policy' do
        let(:query) do
          graphql_query_for(
            'project',
            { 'fullPath' => project.full_path },
            query_graphql_field('incidentManagementEscalationPolicy', { id: policy.to_global_id.to_s }, all_graphql_fields_for('EscalationPolicyType'))
          )
        end

        it_behaves_like 'a working graphql query'

        it 'returns the correct properties of the escalation policy' do
          policy_data = graphql_data.dig('project', 'incidentManagementEscalationPolicy')

          expect(policy_data).to include(
            'id' => policy.to_global_id.to_s,
            'name' => policy.name,
            'description' => policy.description
          )
        end
      end
    end
  end
end
