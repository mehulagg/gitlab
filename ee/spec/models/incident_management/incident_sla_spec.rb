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

  describe 'scopes' do
    describe '.exceeded' do
      subject { described_class.exceeded }

      let_it_be(:project) { create(:project) }
      let!(:incident_sla) { create(:incident_sla, issue: issue, due_at: due_at) }
      let(:due_at) { Time.current - 1.hour }
      let(:issue) { create(:issue, project: project) }

      context 'issue closed' do
        let(:issue) { create(:issue, :closed, project: project) }

        it { is_expected.to be_empty }
      end

      context 'issue opened' do
        context 'due_at has not passed' do
          let(:due_at) { Time.current + 1.hour }

          it { is_expected.to be_empty }
        end

        it { is_expected.to contain_exactly(incident_sla) }
      end
    end
  end
end
