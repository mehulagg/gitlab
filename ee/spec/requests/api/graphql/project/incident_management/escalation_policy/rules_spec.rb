# frozen_string_literal: true

require 'spec_helper'

RSpec.describe 'getting Incident Management escalation policies' do
  include GraphqlHelpers

  let_it_be(:current_user) { create(:user) }
  let_it_be(:project) { create(:project) }
  let_it_be(:policy) { create(:incident_management_escalation_policy, project: project) }
  let_it_be(:rule) { policy.rules.first }
  let_it_be(:schedule) { rule.oncall_schedule }

  let(:params) { {} }

  let(:fields) do
    <<~QUERY
      nodes {
        id
        rules {
          id
          elapsedTimeSeconds
          status
          oncallSchedule {
            iid
            name
          }
        }
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

  let(:escalation_policy_response) { graphql_data.dig('project', 'incidentManagementEscalationPolicies', 'nodes').first }
  let(:escalation_rules_response) { escalation_policy_response['rules'] }

  before do
    stub_licensed_features(oncall_schedules: true, escalation_policies: true)
    project.add_reporter(current_user)
  end

  it 'includes expected data' do
    post_graphql(query, current_user: current_user)

    expect(escalation_rules_response).to eq([{
      'id' => rule.to_global_id.to_s,
      'elapsedTimeSeconds' => rule.elapsed_time_seconds, # 5 min
      'status' => rule.status.upcase, # 'ACKNOWLEDGED'
      'oncallSchedule' => {
        'iid' => schedule.iid.to_s,
        'name' => schedule.name
      }
    }])
  end

  context 'with multiple rules' do
    let_it_be(:later_acknowledged_rule) { create(:incident_management_escalation_rule, policy: policy, elapsed_time_seconds: 10.minutes) }
    let_it_be(:earlier_resolved_rule) { create(:incident_management_escalation_rule, :resolved, policy: policy, elapsed_time_seconds: 1.minute) }
    let_it_be(:equivalent_resolved_rule) { create(:incident_management_escalation_rule, :resolved, policy: policy) }

    it 'orders rules by time and status' do
      post_graphql(query, current_user: current_user)

      expect(escalation_rules_response.length).to eq(4)
      expect(pluck_from_rules_response('elapsedTimeSeconds')).to eq([1.minute, 5.minutes, 5.minutes, 10.minutes])
      expect(pluck_from_rules_response('status')).to eq(%w(RESOLVED ACKNOWLEDGED RESOLVED ACKNOWLEDGED))
    end
  end

  it 'avoids N+1 queries' do
    post_graphql(query, current_user: current_user)

    base_count = ActiveRecord::QueryRecorder.new do
      post_graphql(query, current_user: current_user)
    end

    create(:incident_management_escalation_rule, policy: policy, elapsed_time_seconds: 1.hour)

    expect { post_graphql(query, current_user: current_user) }.not_to exceed_query_limit(base_count)
  end

  private

  def pluck_from_rules_response(attribute)
    escalation_rules_response.map { |rule| rule[attribute] }
  end
end
