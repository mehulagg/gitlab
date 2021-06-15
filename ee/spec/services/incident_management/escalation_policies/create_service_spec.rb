# frozen_string_literal: true

require 'spec_helper'

RSpec.describe IncidentManagement::EscalationPolicies::CreateService do
  let_it_be_with_refind(:project) { create(:project) }
  let_it_be(:user_with_permissions) { create(:user) }
  let_it_be(:oncall_schedule) { create(:incident_management_oncall_schedule, project: project) }

  let(:user) { user_with_permissions }

  before do
    stub_licensed_features(oncall_schedules: true, escalation_policies: true)
  end

  before_all do
    project.add_maintainer(user_with_permissions)
  end

  let(:rule_params) do
    [
      {
        oncall_schedule_id: oncall_schedule.id,
        elapsed_time_seconds: 60,
        status: :resolved
      }
    ]
  end

  let(:params) { { name: 'Policy', description: 'Description', rules_attributes: rule_params } }
  let(:service) { described_class.new(project, user, params) }

  describe '#execute' do
    subject(:execute) { service.execute }

    shared_examples 'error response' do |message|
      it 'does not save the policy and has an informative message' do
        expect { execute }.not_to change(IncidentManagement::EscalationPolicy, :count)
        expect(execute).to be_error
        expect(execute.message).to eq(message)
      end
    end

    context 'when user does not have access' do
      let(:user) { create(:user) }

      it_behaves_like 'error response', 'You have insufficient permissions to create an escalation policy for this project'
    end

    context 'when license is not enabled' do
      before do
        stub_licensed_features(oncall_schedules: true, escalation_policies: false)
      end

      it_behaves_like 'error response', 'Escalation policies are not supported for this project'
    end

    context 'validation errors' do
      context 'validation error in policy' do
        before do
          params[:name] = ''
        end

        it_behaves_like 'error response', "Name can't be blank"
      end

      context 'no rules are given' do
        let(:rule_params) { nil }

        it_behaves_like 'error response', 'A rule must be provided to create an escalation policy'
      end

      context 'oncall schedule is blank' do
        before do
          rule_params[0][:oncall_schedule_id] = nil
        end

        it_behaves_like 'error response', "Rules[0] oncall schedule can't be blank"
      end
    end

    context 'valid params' do
      it 'creates the policy and rules' do
        expect(execute).to be_success

        policy = execute.payload[:escalation_policy]
        expect(policy).to be_a(::IncidentManagement::EscalationPolicy)
      end
    end
  end
end
