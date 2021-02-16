# frozen_string_literal: true

require 'spec_helper'

RSpec.describe IncidentManagement::OncallRotation do
  let_it_be(:schedule) { create(:incident_management_oncall_schedule) }

  describe '.associations' do
    it { is_expected.to belong_to(:schedule).class_name('OncallSchedule').inverse_of(:rotations) }
    it { is_expected.to have_many(:participants).order(id: :asc).class_name('OncallParticipant').inverse_of(:rotation) }
    it { is_expected.to have_many(:users).through(:participants) }
    it { is_expected.to have_many(:shifts).class_name('OncallShift').inverse_of(:rotation) }
  end

  describe '.validations' do
    subject { build(:incident_management_oncall_rotation, schedule: schedule, name: 'Test rotation') }

    it { is_expected.to validate_presence_of(:name) }
    it { is_expected.to validate_length_of(:name).is_at_most(200) }
    it { is_expected.to validate_uniqueness_of(:name).scoped_to(:oncall_schedule_id) }
    it { is_expected.to validate_presence_of(:starts_at) }
    it { is_expected.to validate_presence_of(:length) }
    it { is_expected.to validate_numericality_of(:length) }
    it { is_expected.to validate_presence_of(:length_unit) }

    context 'when the oncall rotation with the same name exists' do
      before do
        create(:incident_management_oncall_rotation, schedule: schedule, name: 'Test rotation')
      end

      it 'has validation errors' do
        expect(subject).to be_invalid
        expect(subject.errors.full_messages.to_sentence).to eq('Name has already been taken')
      end
    end

    describe 'interval start/end time' do
      context 'missing values' do
        before do
          allow(subject).to receive(stubbed_field).and_return(Time.current)
        end

        context 'start time set' do
          let(:stubbed_field) { :interval_start }

          it { is_expected.to validate_presence_of(:interval_end) }
        end

        context 'end time set' do
          let(:stubbed_field) { :interval_end }

          it { is_expected.to validate_presence_of(:interval_start) }
        end
      end

      context 'hourly shifts' do
        subject { build(:incident_management_oncall_rotation, schedule: schedule, name: 'Test rotation', length_unit: :hours) }

        it 'raises a validation error if an interval is set' do
          subject.interval_start = Time.current
          subject.interval_end = Time.current

          expect(subject.valid?).to eq(false)
          expect(subject.errors.full_messages).to include(/Restricted shift times are not available for hourly shifts/)
        end
      end
    end
  end

  describe 'scopes' do
    describe '.started' do
      subject { described_class.started }

      let_it_be(:rotation_1) { create(:incident_management_oncall_rotation, schedule: schedule) }
      let_it_be(:rotation_2) { create(:incident_management_oncall_rotation, schedule: schedule, starts_at: 1.week.from_now) }

      it { is_expected.to contain_exactly(rotation_1) }
    end
  end

  describe '#shift_cycle_duration' do
    let_it_be(:rotation) { create(:incident_management_oncall_rotation, schedule: schedule, length: 5, length_unit: :days) }

    subject { rotation.shift_cycle_duration }

    it { is_expected.to eq(5.days) }

    described_class.length_units.each_key do |unit|
      context "with a length unit of #{unit}" do
        let(:rotation) { build(:incident_management_oncall_rotation, schedule: schedule, length_unit: unit) }

        it { is_expected.to be_a(ActiveSupport::Duration) }
      end
    end
  end
end
