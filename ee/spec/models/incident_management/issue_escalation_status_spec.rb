# frozen_string_literal: true

require 'spec_helper'

RSpec.describe IncidentManagement::IssueEscalationStatus do
  let_it_be(:issue) { create(:issue) }

  subject { build(:incident_management_issue_escalation_status, issue: issue) }

  it { is_expected.to be_valid }

  describe 'associations' do
    it { is_expected.to belong_to(:issue) }
  end

  describe 'validatons' do
    it { is_expected.to validate_presence_of(:issue) }
    it { is_expected.to validate_uniqueness_of(:issue) }
    it { is_expected.to validate_presence_of(:status) }
  end

  describe 'status' do
    let_it_be(:escalatable_factory) { :incident_management_issue_escalation_status }

    it_behaves_like 'an Escalatable model'
  end
end
