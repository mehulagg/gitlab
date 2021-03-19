# frozen_string_literal: true

RSpec.shared_examples_for 'credentials inventory delete SSH key' do |group_managed_account: false|
  include AdminModeHelper

  let_it_be(:user) { group_managed_account ? managed_users.last : create(:user, name: 'abc') }
  let_it_be(:ssh_key) { create(:personal_key, user: user) }

  let(:ssh_key_id) { ssh_key.id }

  if group_managed_account
    subject { delete group_security_credential_path(group_id: group_with_managed_accounts.to_param, id: ssh_key_id) }
  else
    subject { delete admin_credential_path(id: ssh_key_id) }
  end

  context 'admin user' do
    before do
      unless group_managed_account
        sign_in(admin)
        enable_admin_mode!(admin)
      end
    end

    context 'when `credentials_inventory` feature is enabled' do
      before do
        if group_managed_account
          stub_licensed_features(credentials_inventory: true, group_saml: true)
        else
          stub_licensed_features(credentials_inventory: true)
        end
      end

      context 'and the ssh_key exists' do
        context 'and it removes the key' do
          it 'renders a success message' do
            subject

            expect(response).to redirect_to(credentials_path)
            expect(flash[:notice]).to eql 'User key was successfully removed.'
          end

          it 'notifies the key owner' do
            perform_enqueued_jobs do
              expect { subject }.to change { ActionMailer::Base.deliveries.size }.by(1)
            end
          end
        end

        context 'and it fails to remove the key' do
          before do
            allow_next_instance_of(Keys::DestroyService) do |service|
              allow(service).to receive(:execute).and_return(false)
            end
          end

          it 'renders a failure message' do
            subject

            expect(response).to redirect_to(credentials_path)
            expect(flash[:notice]).to eql 'Failed to remove user key.'
          end
        end
      end

      context 'and the ssh_key does not exist' do
        let(:ssh_key_id) { 999999999999999999999999999999999 }

        it 'renders a not found message' do
          subject

          expect(response).to have_gitlab_http_status(:not_found)
        end
      end
    end

    context 'when `credentials_inventory` feature is disabled' do
      before do
        stub_licensed_features(credentials_inventory: false)
      end

      it 'returns 404' do
        subject

        expect(response).to have_gitlab_http_status(:not_found)
      end
    end
  end

  context 'non-admin user' do
    before do
      sign_in(user)
    end

    it 'returns 404' do
      subject

      expect(response).to have_gitlab_http_status(:not_found)
    end
  end
end
