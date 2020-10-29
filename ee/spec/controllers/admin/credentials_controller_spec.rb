# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Admin::CredentialsController do
  let_it_be(:admin) { create(:admin) }
  let_it_be(:user) { create(:user) }
  let_it_be(:personal_access_token) { create(:personal_access_token, user: user) }

  describe 'GET #index' do
    context 'admin user' do
      before do
        sign_in(admin)
      end

      context 'when `credentials_inventory` feature is enabled' do
        before do
          stub_licensed_features(credentials_inventory: true)
        end

        it 'responds with 200' do
          get :index

          expect(response).to have_gitlab_http_status(:ok)
        end

        it_behaves_like 'tracking unique visits', :index do
          let(:target_id) { 'i_compliance_credential_inventory' }
        end

        describe 'filtering by type of credential' do
          let_it_be(:personal_access_tokens) { create_list(:personal_access_token, 2, user: user) }

          shared_examples_for 'filtering by `personal_access_tokens`' do
            specify do
              get :index, params: params

              expect(assigns(:credentials)).to match_array(user.personal_access_tokens)
            end
          end

          context 'no credential type specified' do
            let(:params) { {} }

            it_behaves_like 'filtering by `personal_access_tokens`'
          end

          context 'non-existent credential type specified' do
            let(:params) { { filter: 'non_existent_credential_type' } }

            it_behaves_like 'filtering by `personal_access_tokens`'
          end

          context 'credential type specified as `personal_access_tokens`' do
            let(:params) { { filter: 'personal_access_tokens' } }

            it_behaves_like 'filtering by `personal_access_tokens`'
          end

          context 'credential type specified as `ssh_keys`' do
            it 'filters by ssh keys' do
              ssh_keys =  create_list(:personal_key, 2, user: user)

              get :index, params: { filter: 'ssh_keys' }

              expect(assigns(:credentials)).to match_array(ssh_keys)
            end
          end
        end
      end

      context 'when `credentials_inventory` feature is disabled' do
        before do
          stub_licensed_features(credentials_inventory: false)
        end

        it 'returns 404' do
          get :index

          expect(response).to have_gitlab_http_status(:not_found)
        end
      end
    end

    context 'non-admin user' do
      before do
        sign_in(user)
      end

      it 'returns 404' do
        get :index

        expect(response).to have_gitlab_http_status(:not_found)
      end
    end
  end

  describe 'POST #destroy' do
    let(:credentials_path) { admin_credentials_path(filter: 'ssh_keys') }

    it_behaves_like 'credentials inventory controller delete SSH key'
  end

  describe 'PUT #revoke' do
    context 'admin user' do
      before do
        sign_in(admin)
      end

      context 'when `credentials_inventory` feature is enabled' do
        before do
          stub_licensed_features(credentials_inventory: true)
        end

        context 'non-existent personal access token specified' do
          it 'returns 404' do
            put :revoke, params: { id: 999999999999999999999999999999999 }

            expect(response).to have_gitlab_http_status(:not_found)
          end
        end

        describe 'with an existing personal access token' do
          context 'does not have permissions to revoke the credential' do
            before do
              allow(Ability).to receive(:allowed?).with(admin, :log_in, :global) { true }
              allow(Ability).to receive(:allowed?).with(admin, :revoke_token, personal_access_token) { false }
            end

            it 'returns the flash error message' do
              put :revoke, params: { id: personal_access_token.id }

              expect(response).to redirect_to(admin_credentials_path)
              expect(flash[:alert]).to eql 'Not permitted to revoke'
            end
          end

          context 'personal access token is already revoked' do
            let_it_be(:personal_access_token) { create(:personal_access_token, revoked: true, user: user) }

            it 'returns the flash success message' do
              put :revoke, params: { id: personal_access_token.id }

              expect(response).to redirect_to(admin_credentials_path)
              expect(flash[:notice]).to eql 'Revoked personal access token %{personal_access_token_name}!' % { personal_access_token_name: personal_access_token.name }
            end
          end

          context 'personal access token is already expired' do
            let_it_be(:personal_access_token) { create(:personal_access_token, expires_at: 5.days.ago, user: user) }

            it 'returns the flash success message' do
              put :revoke, params: { id: personal_access_token.id }

              expect(response).to redirect_to(admin_credentials_path)
              expect(flash[:notice]).to eql 'Revoked personal access token %{personal_access_token_name}!' % { personal_access_token_name: personal_access_token.name }
            end
          end

          context 'personal access token is not revoked or expired' do
            it 'returns the flash success message' do
              put :revoke, params: { id: personal_access_token.id }

              expect(response).to redirect_to(admin_credentials_path)
              expect(flash[:notice]).to eql 'Revoked personal access token %{personal_access_token_name}!' % { personal_access_token_name: personal_access_token.name }
            end

            it 'informs the token owner' do
              expect(CredentialsInventoryMailer).to receive_message_chain(:personal_access_token_revoked_email, :deliver_later)

              put :revoke, params: { id: personal_access_token.id }
            end

            context 'when credentials_inventory_revocation_emails flag is disabled' do
              before do
                stub_feature_flags(credentials_inventory_revocation_emails: false)
              end

              it 'does not inform the token owner' do
                expect do
                  put :revoke, params: { id: personal_access_token.id }
                end.not_to change { ActionMailer::Base.deliveries.size }
              end
            end
          end
        end
      end

      context 'when `credentials_inventory` feature is disabled' do
        before do
          stub_licensed_features(credentials_inventory: false)
        end

        it 'returns 404' do
          put :revoke, params: { id: personal_access_token.id }

          expect(response).to have_gitlab_http_status(:not_found)
        end
      end
    end

    context 'non-admin user' do
      before do
        sign_in(user)
      end

      it 'returns 404' do
        put :revoke, params: { id: personal_access_token.id }

        expect(response).to have_gitlab_http_status(:not_found)
      end
    end
  end
end
