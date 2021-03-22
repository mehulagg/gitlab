# frozen_string_literal: true

require 'spec_helper'

RSpec.describe ::EE::Gitlab::Scim::DeprovisionService do
  describe '#execute' do
    let_it_be(:identity) { create(:scim_identity, active: true) }
    let_it_be(:group) { identity.group }
    let_it_be(:user) { identity.user }

    let(:service) { described_class.new(identity) }

    context 'when user is successfully removed' do
      before do
        create(:group_member, group: group, user: user, access_level: GroupMember::REPORTER)
      end

      it 'deactivates scim identity' do
        service.execute

        expect(identity.active).to be false
      end

      it 'removes group access' do
        service.execute

        expect(group.members.pluck(:user_id)).not_to include(user.id)
      end
    end

    context 'when user is not successfully removed' do
      context 'when user is the last owner' do
        before do
          create(:group_member, group: group, user: user, access_level: GroupMember::OWNER)
        end

        it 'does not remove the last owner' do
          service.execute

          expect(identity.group.members.pluck(:user_id)).to include(user.id)
        end

        it 'returns the last group owner error' do
          response = service.execute

          expect(response.error?).to be true
          expect(response.errors).to include("Did not remove user from group: Cannot remove last group owner.")
        end
      end

      context 'when user is not a group member' do
        it 'does not change group membership when the user is not a member' do
          expect { service.execute }.not_to change { group.members.count }
        end

        it 'returns the group membership error' do
          response = service.execute

          expect(response.error?).to be true
          expect(response.errors).to include("Did not remove user from group: User is not a group member.")
        end
      end
    end
  end
end
