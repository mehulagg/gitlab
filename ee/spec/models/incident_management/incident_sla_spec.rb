# frozen_string_literal: true

require 'spec_helper'

RSpec.describe IncidentManagement::IncidentSla do
  subject(:incident_sla) { build(:incident_sla) }

  it { is_expected.to be_valid }

  describe 'associations' do
    it { is_expected.to belong_to(:issue).required }
  end

  describe 'validations' do
    it { is_expected.to validate_presence_of(:due_at) }
  end
end
