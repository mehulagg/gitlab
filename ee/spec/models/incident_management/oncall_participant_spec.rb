# frozen_string_literal: true

require 'spec_helper'

RSpec.describe IncidentManagement::OncallParticipant do
  let_it_be(:rotation) { create(:incident_management_oncall_rotation) }
  let_it_be(:user) { create(:user) }

  subject { build(:incident_management_oncall_participant, oncall_rotation: rotation, user: user) }

  before_all do
    rotation.project.add_developer(user)
  end

  describe '.associations' do
    it { is_expected.to belong_to(:oncall_rotation) }
    it { is_expected.to belong_to(:participant) }
  end

  describe '.validations' do
    it { is_expected.to validate_presence_of(:oncall_rotation) }
    it { is_expected.to validate_presence_of(:participant) }
    it { is_expected.to validate_length_of(:color_weight).is_at_most(4) }
    it { is_expected.to validate_length_of(:color_palette).is_at_most(10) }

    context 'when the participant already exists in the rotation' do
      before do
        create(:incident_management_oncall_participant, oncall_rotation: rotation, user: user)
      end

      it 'has validation errors' do
        expect(subject).to be_invalid
        expect(subject.errors.full_messages.to_sentence).to eq('Participant has already been taken')
      end
    end

    context 'when participant cannot read project' do
      subject { build(:incident_management_oncall_participant, oncall_rotation: rotation, user: user) }

      context 'on creation' do
        before do
          rotation.project.members.delete_all
        end

        it 'has validation errors' do
          expect(subject).to be_invalid
          expect(subject.errors.full_messages.to_sentence).to eq('Participant does not have access to the project')
        end
      end

      context 'after creation' do
        it 'is valid' do
          subject.save!
          rotation.project.members.delete_all

          expect(subject).to be_valid
        end
      end
    end
  end
end
