# frozen_string_literal: true

require 'spec_helper'

RSpec.describe IncidentManagement::OncallShift do
  let_it_be(:participant) { create(:incident_management_oncall_participant, :with_developer_access) }

  describe 'associations' do
    it { is_expected.to belong_to(:rotation) }
    it { is_expected.to belong_to(:participant) }
  end

  describe 'validations' do
    subject { build(:incident_management_oncall_shift) }

    it { is_expected.to validate_presence_of(:starts_at) }
    it { is_expected.to validate_presence_of(:ends_at) }
    it { is_expected.to validate_presence_of(:rotation) }
    it { is_expected.to validate_presence_of(:participant) }

    describe 'for timeframe' do
      let_it_be(:shift_start) { Time.current }
      let_it_be(:shift_end) { shift_start + 1.day }
      let_it_be(:existing_shift) { create_shift(shift_start, shift_end, participant) }

      subject { build_shift(starts_at, ends_at, participant) }

      context 'when the new shift does not conflict' do
        let(:starts_at) { shift_end }
        let(:ends_at) { shift_end + 5.hours }

        it { is_expected.to be_valid }
      end

      context 'when the new shift conflicts' do
        let(:starts_at) { shift_start + 5.hours }
        let(:ends_at) { shift_end + 5.hours }

        specify do
          expect(subject).to be_invalid
          expect(subject.errors.full_messages.to_sentence).to eq('Shift timeframe cannot overlap with other existing shifts')
        end
      end
    end
  end

  describe 'scopes' do
    let_it_be(:monday) { Time.current.next_week(:monday) }
    let_it_be(:tuesday) { monday + 1.day }
    let_it_be(:wednesday) { tuesday + 1.day }
    let_it_be(:thursday) { wednesday + 1.day }
    let_it_be(:friday) { thursday + 1.day }
    let_it_be(:saturday) { friday + 1.day }
    let_it_be(:sunday) { saturday + 1.day }

    # Using multiple participants in different rotations
    # to be able to simultaneously save shifts which would
    # conflict if they were part of the same rotation
    let_it_be(:participant2) { create(:incident_management_oncall_participant, :with_developer_access) }
    let_it_be(:participant3) { create(:incident_management_oncall_participant, :with_developer_access) }

    # First rotation
    let_it_be(:mon_to_tue) { create_shift(monday, tuesday, participant) }
    let_it_be(:tue_to_wed) { create_shift(tuesday, wednesday, participant) }
    let_it_be(:wed_to_thu) { create_shift(wednesday, thursday, participant) }
    let_it_be(:thu_to_fri) { create_shift(thursday, friday, participant) }
    let_it_be(:fri_to_sat) { create_shift(friday, saturday, participant) }
    let_it_be(:sat_to_sun) { create_shift(saturday, sunday, participant) }

    # Second rotation
    let_it_be(:mon_to_thu) { create_shift(monday, thursday, participant2) }
    let_it_be(:fri_to_sun) { create_shift(friday, sunday, participant2) }

    # Third rotation
    let_it_be(:tue_to_sun) { create_shift(tuesday, sunday, participant3) }

    describe '.for_timeframe' do
      subject(:shifts) { described_class.for_timeframe(wednesday, saturday) }

      it 'includes shifts which cover the timeframe' do
        expect(shifts).to contain_exactly(
          mon_to_thu, # Overlaps start time
          wed_to_thu, # Coinciding start times
          thu_to_fri, # Completely contained
          fri_to_sat, # Coinciding end times
          fri_to_sun, # Overlapping end time
          tue_to_sun # Covers entire timeframe
        )
        # Excluded shifts:
        # mon_to_tue - Completely before timeframe
        # tue_to_wed - Ends as timeframe starts
        # sat_to_sun - Starts as timeframe ends
      end

      context 'for invalid timeframe' do
        subject { described_class.for_timeframe(saturday, friday) }

        it { is_expected.to eq described_class.none }
      end
    end

    describe '.order_starts_at_desc' do
      subject { described_class.order_starts_at_desc }

      it do
        is_expected.to eq [
          sat_to_sun,
          fri_to_sun,
          fri_to_sat,
          thu_to_fri,
          wed_to_thu,
          tue_to_sun,
          tue_to_wed,
          mon_to_thu,
          mon_to_tue
        ]
      end
    end

    describe '.for_timestamp' do
      subject(:shifts) { described_class.for_timestamp(wednesday) }

      it 'includes shifts which cover the timestamp' do
        expect(shifts).to contain_exactly(
          mon_to_thu, # Covers timestamp
          wed_to_thu, # Starts at timestamp
          tue_to_sun # Covers timestamp
        )
        # Notable excluded shift: tue_to_wed (Ends at timestamp)
      end
    end
  end

  private

  def create_shift(starts_at, ends_at, participant)
    create(:incident_management_oncall_shift, starts_at: starts_at, ends_at: ends_at, participant: participant, rotation: participant.rotation)
  end

  def build_shift(starts_at, ends_at, participant)
    build(:incident_management_oncall_shift, starts_at: starts_at, ends_at: ends_at, participant: participant, rotation: participant.rotation)
  end
end
