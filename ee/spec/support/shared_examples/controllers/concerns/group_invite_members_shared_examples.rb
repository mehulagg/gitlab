# frozen_string_literal: true

RSpec.shared_examples GroupInviteMembers do
  context 'when inviting members', :snowplow do
    context 'without valid emails in the params' do
      it 'only adds creator as member' do
        expect { subject }.to change(Member, :count).by(1)
      end

      it 'does not track the event' do
        subject

        expect_no_snowplow_event
      end
    end

    context 'with valid emails in the params' do
      before do
        group_params[:emails] = ['a@a.a', 'b@b.b', '', '', 'x', 'y']
      end

      it 'adds users with developer access and ignores blank emails' do
        expect_next_instance_of(Group) do |group|
          expect(group).to receive(:add_users).with(
            %w[a@a.a b@b.b x y],
            Gitlab::Access::DEVELOPER,
            expires_at: nil,
            current_user: user
          ).and_call_original
        end

        subject
      end

      it 'sends invitations to valid emails only' do
        subject

        emails = assigns(:group).members.pluck(:invite_email)

        expect(emails).to include('a@a.a', 'b@b.b')
        expect(emails).not_to include('x', 'y')
      end

      it 'tracks the event' do
        subject

        expect_snowplow_event(category: anything, action: 'invite_members', label: 'new_group_form')
      end
    end
  end
end
