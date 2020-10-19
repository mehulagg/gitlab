# frozen_string_literal: true

require "spec_helper"

RSpec.describe InviteMembersHelper do
  let_it_be(:project) { create(:project) }
  let_it_be(:developer) { create(:user, developer_projects: [project]) }
  let(:owner) { project.owner }

  before do
    assign(:project, project)
  end

  describe "#directly_invite_members?" do
    context 'when the user is an owner' do
      before do
        allow(helper).to receive(:current_user) { owner }
      end

      it 'returns false' do
        allow(helper).to receive(:experiment_enabled?).with(:invite_members_version_a) { false }

        expect(helper.directly_invite_members?).to eq false
      end

      it 'returns true' do
        allow(helper).to receive(:experiment_enabled?).with(:invite_members_version_a) { true }

        expect(helper.directly_invite_members?).to eq true
      end
    end

    context 'when the user is a developer' do
      before do
        allow(helper).to receive(:current_user) { developer }
      end

      it 'returns false' do
        allow(helper).to receive(:experiment_enabled?).with(:invite_members_version_a) { true }

        expect(helper.directly_invite_members?).to eq false
      end
    end
  end

  describe "#indirectly_invite_members?" do
    context 'when a user is a developer' do
      before do
        allow(helper).to receive(:current_user) { developer }
      end

      it 'returns false' do
        allow(helper).to receive(:experiment_enabled?).with(:invite_members_version_b) { false }

        expect(helper.indirectly_invite_members?).to eq false
      end

      it 'returns true' do
        allow(helper).to receive(:experiment_enabled?).with(:invite_members_version_b) { true }

        expect(helper.indirectly_invite_members?).to eq true
      end
    end

    context 'when a user is an owner' do
      before do
        allow(helper).to receive(:current_user) { owner }
      end

      it 'returns false' do
        allow(helper).to receive(:experiment_enabled?).with(:invite_members_version_b) { true }

        expect(helper.indirectly_invite_members?).to eq false
      end
    end
  end
end
