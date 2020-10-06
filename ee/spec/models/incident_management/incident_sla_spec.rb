# frozen_string_literal: true

require 'spec_helper'

RSpec.describe IncidentManagement::IncidentSla do
  subject(:incident_sla) { build(:incident_sla) }

  it { is_expected.to be_valid }

  describe 'validations' do
    it { is_expected.to validate_presence_of(:due_at) }

    it 'requires an issue' do
      expect(build(:incident_sla, issue: nil).valid? ).to eq(false)
    end
  end
end
