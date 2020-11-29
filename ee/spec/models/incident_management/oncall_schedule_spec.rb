# frozen_string_literal: true

require 'spec_helper'

RSpec.describe IncidentManagement::OncallSchedule do
  let_it_be(:project) { create(:project) }

  describe '.associations' do
    it { is_expected.to belong_to(:project) }
  end

  describe '.validations' do
    let(:timezones) { ActiveSupport::TimeZone.all.map { |tz| tz.tzinfo.identifier } }

    subject { build(:incident_management_oncall_schedule, project: project) }

    it { is_expected.to validate_presence_of(:name) }
    it { is_expected.to validate_length_of(:name).is_at_most(200) }
    it { is_expected.to validate_length_of(:description).is_at_most(1000) }
    it { is_expected.to validate_presence_of(:timezone) }
    it { is_expected.to validate_inclusion_of(:timezone).in_array(timezones) }

    context 'when the oncall schedule with the same name exists' do
      before do
        create(:incident_management_oncall_schedule, project: project)
      end

      it 'has validation errors' do
        expect(subject).to be_invalid
        expect(subject.errors.full_messages.to_sentence).to eq('Name has already been taken')
      end
    end
  end

  it_behaves_like 'AtomicInternalId' do
    let(:internal_id_attribute) { :iid }
    let(:instance) { build(:incident_management_oncall_schedule) }
    let(:scope) { :project }
    let(:scope_attrs) { { project: instance.project } }
    let(:usage) { :incident_management_oncall_schedules }
  end
end
