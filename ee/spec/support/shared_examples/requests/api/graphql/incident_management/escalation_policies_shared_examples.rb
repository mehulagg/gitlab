# frozen_string_literal: true

require 'spec_helper'

# Expected variables:
# schedule - IncidentManagement::OncallSchedule
# resolve - method which posts a mutation
# variables - attributes provided to the mutation
RSpec.shared_examples 'correctly reorders escalation rule inputs' do
  context 'when rules are provided out of order' do
    before do
      variables[:rules] = [
        {
          oncallScheduleIid: schedule.iid,
          elapsedTimeSeconds: 60,
          status: 'RESOLVED'
        },
        {
          oncallScheduleIid: schedule.iid,
          elapsedTimeSeconds: 60,
          status: 'ACKNOWLEDGED'
        },
        {
          oncallScheduleIid: schedule.iid,
          elapsedTimeSeconds: 0,
          status: 'ACKNOWLEDGED'
        }
      ]
    end

    it 'successfully creates the policy and reorders the rules' do
      resolve

      expect(response).to have_gitlab_http_status(:success)
      expect(mutation_response['errors']).to be_empty
      expect(pluck_from_rules_response('status')).to eq(%w(ACKNOWLEDGED ACKNOWLEDGED RESOLVED))
      expect(pluck_from_rules_response('elapsedTimeSeconds')).to eq([0, 60, 60])
    end

    private

    def pluck_from_rules_response(attribute)
      mutation_response['escalationPolicy']['rules'].map { |rule| rule[attribute] }
    end
  end
end
