# frozen_string_literal: true

require 'spec_helper'

RSpec.describe IncidentManagement::Escalations::ProcessService do
  let_it_be(:project) { create(:project) }

  let(:escalation) { create(:alert_escalation, policy: policy, alert: alert) }

  context 'all conditions are met' do
    it 'escalates';
    it 'updates the escalation time';

    context 'feature flag is off' do
      it 'does not escalate';
    end
  end

  describe 'non-escalate conditions' do
    context 'alert status not valid' do
      it 'does not escalate';
    end

    context 'not enough time elapsed' do
      it 'does not escalate';
    end

    context 'rule previously escalated' do
      it 'does not escalate';
    end
  end
end
