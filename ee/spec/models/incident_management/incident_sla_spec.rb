# frozen_string_literal: true

require 'spec_helper'

RSpec.describe IncidentManagement::IncidentSla do
  let_it_be(:incident_sla) { create(:incident_sla) }
  subject { incident_sla }

  it { expect(subject).to be_valid }

  describe 'validations' do
    it { is_expected.to validate_presence_of(:due_at) }
    it { is_expected.to validate_presence_of(:issue) }
  end
end
