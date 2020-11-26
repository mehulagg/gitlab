# frozen_string_literal: true

require 'spec_helper'

RSpec.describe SetUserStatusBasedOnUserCapSettingWorker, type: :worker do
  let_it_be(:active_user) { create(:user, state: 'active') }

  describe '#perform' do
    let_it_be(:user) { create(:user, :blocked_pending_approval) }
    let(:new_user_signups_cap) { 10 }

    subject { described_class.new.perform(user.id) }

    before do
      allow(Gitlab::CurrentSettings).to receive(:new_user_signups_cap).and_return(new_user_signups_cap)
    end

    context 'when user is not blocked_pending_approval' do
      let(:user) { active_user }

      it 'does nothing to the user state' do
        subject

        expect(user.reload).to be_active
      end
    end

    context 'when user cap is set to nil' do
      let(:new_user_signups_cap) { nil }

      it 'does nothing to the user state' do
        subject

        expect(user.reload).to be_blocked_pending_approval
      end
    end

    context 'when current billable user count is less than user cap' do
      it 'activates the user' do
        subject

        expect(user.reload).to be_active
      end

      it 'notifies the approval to the user' do
        expect(DeviseMailer).to receive(:user_admin_approval).with(user).and_call_original
        expect { subject }.to have_enqueued_mail(DeviseMailer, :user_admin_approval)
      end

      context 'when user has not confirmed their email yet' do
        let(:user) { create(:user, :blocked_pending_approval, :unconfirmed) }

        it 'sends confirmation instructions' do
          expect { subject }
            .to have_enqueued_mail(DeviseMailer, :confirmation_instructions)
        end
      end

      context 'when user has confirmed their email' do
        it 'does not send a confirmation email' do
          expect { subject }
            .not_to have_enqueued_mail(DeviseMailer, :confirmation_instructions)
        end
      end

      context 'when pending invitations' do
        let!(:project_member_invite) { create(:project_member, :invited, invite_email: user.email) }
        let!(:group_member_invite) { create(:group_member, :invited, invite_email: user.email) }

        context 'when user is unconfirmed' do
          let(:user) { create(:user, :blocked_pending_approval, :unconfirmed) }

          it 'does not accept pending invites of the user' do
            subject

            group_member_invite.reload
            project_member_invite.reload

            expect(group_member_invite).to be_invite
            expect(project_member_invite).to be_invite
          end
        end

        context 'when user is confirmed' do
          it 'accepts pending invites of the user' do
            subject

            group_member_invite.reload
            project_member_invite.reload

            expect(group_member_invite).not_to be_invite
            expect(project_member_invite).not_to be_invite
            expect(group_member_invite.user).to eq(user)
            expect(project_member_invite.user).to eq(user)
          end
        end
      end
    end

    context 'when current billable user count is equal to user cap' do
      let(:new_user_signups_cap) { 1 }

      it 'keeps the user in blocked_pending_approval state' do
        subject

        expect(user.reload).to be_blocked_pending_approval
      end
    end
  end
end
