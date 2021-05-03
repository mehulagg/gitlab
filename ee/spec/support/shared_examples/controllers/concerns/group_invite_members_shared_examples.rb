# frozen_string_literal: true

RSpec.shared_examples GroupInviteMembers do
  context 'when inviting members', :snowplow do
    context 'without valid emails in the params' do
      it 'no invites generated by default' do
        subject

        expect(assigns(:group).members.invite).to be_empty
      end

      it 'does not track the event' do
        subject

        expect_no_snowplow_event
      end
    end

    context 'with valid emails in the params' do
      let(:valid_emails) { %w[a@a.a b@b.b] }

      before do
        group_params[:emails] = valid_emails + ['', '', 'x', 'y']
      end

      it 'adds users with developer access and ignores blank and invalid emails' do
        subject

        expect(assigns(:group).members.invite.pluck(:invite_email)).to match_array(valid_emails)
      end

      it 'tracks the event' do
        subject

        expect_snowplow_event(category: anything, action: 'invite_members', label: 'new_group_form')
      end
    end
  end
end
