# frozen_string_literal: true

require 'spec_helper'

RSpec.describe ::EE::Gitlab::Scim::DeprovisionService do
  describe '#execute' do
    let_it_be(:identity) { create(:scim_identity, active: true) }
    let_it_be(:group) { identity.group }
    let_it_be(:user) { identity.user }

    let(:service) { described_class.new(identity) }

    it 'deactivates scim identity' do
      service.execute

      expect(identity.active).to be false
    end

    it 'removes group access' do
      create(:group_member, group: group, user: user, access_level: GroupMember::REPORTER)

      service.execute

      expect(group.members.pluck(:user_id)).not_to include(user.id)
    end

    it 'does not remove the last owner' do
      create(:group_member, group: group, user: user, access_level: GroupMember::OWNER)

      service.execute

      expect(identity.group.members.pluck(:user_id)).to include(user.id)
    end

    it 'does not change group membership when the user is not a member' do
      expect { service.execute }.not_to change { group.members.count }
    end
  end
end
