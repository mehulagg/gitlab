# frozen_string_literal: true

require 'spec_helper'

RSpec.describe IncidentManagement::EscalationPolicy do
  subject { build(:incident_management_escalation_policy) }

  it { is_expected.to be_valid }

  describe 'associations' do
    it { is_expected.to belong_to(:project) }
    it { is_expected.to have_many(:rules) }
    it { is_expected.to have_many(:ordered_rules).order(elapsed_time_seconds: :asc, status: :asc) }
  end

  describe 'validations' do
    it { is_expected.to validate_presence_of(:name) }
    it { is_expected.to validate_presence_of(:rules) }
    it { is_expected.to validate_uniqueness_of(:project_id).with_message(/can only have one escalation policy/).on(:create) }
    it { is_expected.to validate_uniqueness_of(:name).scoped_to(:project_id) }
    it { is_expected.to validate_length_of(:name).is_at_most(72) }
    it { is_expected.to validate_length_of(:description).is_at_most(160) }
  end

  describe '#pending_escalation_alert_ids' do
    let_it_be(:policy) { create(:incident_management_escalation_policy, rule_count: 2) }
    let_it_be(:escalation_1) { create(:incident_management_pending_alert_escalation, rule: policy.rules.first, project: policy.project) }
    let_it_be(:escalation_2) { create(:incident_management_pending_alert_escalation, rule: policy.rules.last, project: policy.project) }
    let_it_be(:escalation_from_other_policy) { create(:incident_management_pending_alert_escalation) }

    subject { policy.pending_escalation_alert_ids }

    it { is_expected.to contain_exactly(escalation_1.alert_id, escalation_2.alert_id) }
  end
end
