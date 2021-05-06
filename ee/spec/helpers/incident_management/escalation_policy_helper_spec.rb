# frozen_string_literal: true

require 'spec_helper'

RSpec.describe IncidentManagement::EscalationPolicyHelper do
  describe '#escalation_policy_data' do
    subject(:data) { helper.escalation_policy_data }

    it 'returns scalation policies data' do
      is_expected.to eq(
        'empty_escalation_policies_svg_path' => helper.image_path('illustrations/empty-state/empty-escalation.svg')
      )
    end
  end
end
