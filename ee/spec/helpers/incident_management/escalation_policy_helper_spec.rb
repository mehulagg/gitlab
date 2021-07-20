# frozen_string_literal: true

require 'spec_helper'

RSpec.describe IncidentManagement::EscalationPolicyHelper do
  let_it_be(:project) { create(:project) }

  describe '#escalation_policy_data' do
    subject(:data) { helper.escalation_policy_data(project) }

    it 'returns scalation policies data' do
      is_expected.to eq(
        'project-path' => project.full_path,
        'empty_escalation_policies_svg_path' => helper.image_path('illustrations/empty-state/empty-escalation.svg')
      )
    end
  end
end
