# frozen_string_literal: true

require 'spec_helper'

RSpec.describe IncidentManagement::IssuableEscalationStatus do
  let_it_be(:issue) { create(:issue) }

  subject { build(:incident_management_issuable_escalation_status, issue: issue) }

  it { is_expected.to be_valid }

  describe 'associations' do
    it { is_expected.to belong_to(:issue) }
  end

  describe 'validatons' do
    it { is_expected.to validate_presence_of(:issue) }
    it { is_expected.to validate_uniqueness_of(:issue) }
    it { is_expected.to validate_presence_of(:status) }
  end
end
