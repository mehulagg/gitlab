# frozen_string_literal: true

require 'spec_helper'

RSpec.describe IncidentManagement::OncallSchedule do
  let_it_be(:project) { create(:project) }

  describe '.associations' do
    it { is_expected.to belong_to(:project) }
  end

  describe '.validations' do
    subject { build(:incident_management_oncall_schedule, project: project) }

    it { is_expected.to validate_presence_of(:name) }
    it { is_expected.to validate_length_of(:name).is_at_most(200) }
    it { is_expected.to validate_length_of(:description).is_at_most(1000) }
    it { is_expected.to validate_presence_of(:timezone) }
    it { is_expected.to validate_length_of(:timezone).is_at_most(100) }
  end
end
