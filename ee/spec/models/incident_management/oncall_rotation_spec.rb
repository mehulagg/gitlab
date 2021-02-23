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

    context 'with ends_at' do
      let(:starts_at) { Time.current }
      let(:ends_at) { 5.days.from_now }

      subject { build(:incident_management_oncall_rotation, schedule: schedule, starts_at: starts_at, ends_at: ends_at) }

      it { is_expected.to be_valid }

      context 'with ends_at before starts_at' do
        let(:ends_at) { 5.days.ago }

        it 'has validation errors' do
          expect(subject).to be_invalid
          expect(subject.errors.full_messages.to_sentence).to eq('Ends at must be after start')
        end
      end
    end
  end

  describe 'scopes' do
    describe '.in_progress' do
      subject { described_class.in_progress }

      let_it_be(:rotation_1) { create(:incident_management_oncall_rotation, schedule: schedule) }
      let_it_be(:rotation_2) { create(:incident_management_oncall_rotation, schedule: schedule, ends_at: nil) }
      let_it_be(:rotation_3) { create(:incident_management_oncall_rotation, schedule: schedule, starts_at: 1.week.from_now) }
      let_it_be(:rotation_4) { create(:incident_management_oncall_rotation, schedule: schedule, starts_at: 1.week.ago, ends_at: 6.days.ago) }

      it { is_expected.to contain_exactly(rotation_1, rotation_2) }
    end
  end

  describe '#shift_duration' do
    let_it_be(:rotation) { create(:incident_management_oncall_rotation, schedule: schedule, length: 5, length_unit: :days) }

    subject { rotation.shift_duration }

    it { is_expected.to eq(5.days) }

    described_class.length_units.each_key do |unit|
      context "with a length unit of #{unit}" do
        let(:rotation) { build(:incident_management_oncall_rotation, schedule: schedule, length_unit: unit) }

        it { is_expected.to be_a(ActiveSupport::Duration) }
      end
    end
  end
end
