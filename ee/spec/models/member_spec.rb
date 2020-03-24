# frozen_string_literal: true

require 'spec_helper'

describe Member, type: :model do
  describe '#notification_service' do
    it 'returns a NullNotificationService instance for LDAP users' do
      member = described_class.new

      allow(member).to receive(:ldap).and_return(true)

      expect(member.__send__(:notification_service))
        .to be_instance_of(::EE::NullNotificationService)
    end
  end

  describe '#is_using_seat', :aggregate_failures do
    let(:user) { build :user }
    let(:group) { create :group }
    let(:member) { build :group_member, group: group, user: user }

    context 'when hosted on GL.com' do
      before do
        allow(Gitlab).to receive(:com?).and_return true
      end

      it 'calls users check for using the gitlab_com seat method' do
        expect(user).to receive(:using_gitlab_com_seat?).with(group).once.and_return true
        expect(user).not_to receive(:using_license_seat?)
        expect(member.is_using_seat).to be_truthy
      end
    end

    context 'when not hosted on GL.com' do
      before do
        allow(Gitlab).to receive(:com?).and_return false
      end

      it 'calls users check for using the License seat method' do
        expect(user).to receive(:using_license_seat?).with(no_args).and_return true
        expect(user).not_to receive(:using_gitlab_com_seat?)
        expect(member.is_using_seat).to be_truthy
      end
    end
  end

  describe 'Updating max seats counter for GitLab subscription' do
    let!(:group) { create(:group) }
    let!(:member_1) { create(:group_member, :reporter, group: group) }
    let!(:member_2) { create(:group_member, :maintainer, group: group) }
    let!(:gitlab_subscription) { create(:gitlab_subscription, namespace: group) }

    before do
      allow(Gitlab::CurrentSettings.current_application_settings)
        .to receive(:should_check_namespace_plan?).and_return(true)
    end

    context 'on update' do
      it 'updates the max_seats_used counter' do
        expect { member_1.update_attribute(:access_level, GroupMember::DEVELOPER) }
          .to change { gitlab_subscription.reload.max_seats_used }.from(0).to(2)
      end
    end

    context 'on destroy' do
      it 'updates the max_seats_used counter' do
        expect { member_2.destroy }
          .to change { gitlab_subscription.reload.max_seats_used }.from(0).to(1)
      end
    end
  end
end
