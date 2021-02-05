# frozen_string_literal: true

require 'spec_helper'

RSpec.describe IncidentManagement::OncallParticipant do
  let_it_be(:rotation) { create(:incident_management_oncall_rotation) }
  let_it_be(:user) { create(:user) }

  subject { build(:incident_management_oncall_participant, rotation: rotation, user: user) }

  it { is_expected.to be_valid }

  before_all do
    rotation.project.add_developer(user)
  end

  describe 'associations' do
    it { is_expected.to belong_to(:rotation) }
    it { is_expected.to belong_to(:user) }
    it { is_expected.to have_many(:shifts) }
  end

  describe 'validations' do
    it { is_expected.to validate_presence_of(:rotation) }
    it { is_expected.to validate_presence_of(:user) }
    it { is_expected.to validate_presence_of(:color_weight) }
    it { is_expected.to validate_presence_of(:color_palette) }

    context 'when the participant already exists in the rotation' do
      before do
        create(:incident_management_oncall_participant, rotation: rotation, user: user)
      end

      it 'has validation errors' do
        expect(subject).to be_invalid
        expect(subject.errors.full_messages.to_sentence).to eq('User has already been taken')
      end
    end
  end

  describe 'scopes' do
    describe '.ordered_asc' do
      let_it_be(:participant1) { create(:incident_management_oncall_participant, :with_developer_access, rotation: rotation) }
      let_it_be(:participant2) { create(:incident_management_oncall_participant, :with_developer_access, rotation: rotation) }
      let_it_be(:participant3) { create(:incident_management_oncall_participant, :with_developer_access, rotation: rotation) }

      subject { described_class.ordered_asc }

      it { is_expected.to eq([participant1, participant2, participant3]) }
    end
  end

  private

  def remove_user_from_project(user, project)
    Members::DestroyService.new(user).execute(project.project_member(user))
  end
end
