# frozen_string_literal: true

require 'spec_helper'

RSpec.describe IncidentManagement::EscalationPolicy do
  let_it_be(:project) { create(:project) }

  subject { build(:incident_management_escalation_policy) }

  describe 'associations' do
    it { is_expected.to belong_to(:project) }
    it { is_expected.to have_many(:rules) }
  end

  describe 'validations' do
    it { is_expected.to validate_presence_of(:name) }
    it { is_expected.to validate_uniqueness_of(:name).scoped_to(:project_id) }
    it { is_expected.to validate_length_of(:name).is_at_most(72) }
    it { is_expected.to validate_length_of(:description).is_at_most(160) }
  end
end
