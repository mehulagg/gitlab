# frozen_string_literal: true

RSpec.shared_examples GroupInviteMembers do
  context 'inviting members' do
    context 'with no valid emails in the params' do
      it 'does not add members' do
        expect { subject }.to change(Member, :count).by(1)
      end

      it 'does not call the Members::CreateService' do
        expect(Members::CreateService).not_to receive(:new)
      end
    end

    context 'with valid emails in the params' do
      before do
        params[:emails] = ['a@a.a', 'b@b.b', '', '', 'x', 'y']
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
    end
  end
end
