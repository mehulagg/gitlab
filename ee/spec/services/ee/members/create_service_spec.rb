# frozen_string_literal: true

require 'spec_helper'

describe Members::CreateService do
  describe 'Updating max seats counter for GitLab subscription' do
    let(:group) { create(:group) }
    let!(:gitlab_subscription) { create(:gitlab_subscription, namespace: group) }
    let(:user_1) { create(:user) }
    let(:user_2) { create(:user) }
    let(:current_user) { create(:user) }

    before do
      group.add_owner(current_user)

      allow(Gitlab::CurrentSettings.current_application_settings)
          .to receive(:should_check_namespace_plan?).and_return(true)
    end

    it 'updates the max_seats_used counter' do
      params = { user_ids: [user_1.id, user_2.id].join(','), access_level: GroupMember::DEVELOPER }

      expect do
        described_class.new(current_user, params).execute(group)
      end.to change { gitlab_subscription.reload.max_seats_used }.from(0).to(3)
    end
  end
end
