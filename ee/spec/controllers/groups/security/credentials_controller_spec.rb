# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Groups::Security::CredentialsController do
  let_it_be(:group_with_managed_accounts) { create(:group_with_managed_accounts, :private) }
  let_it_be(:managed_users) { create_list(:user, 2, :group_managed, managing_group: group_with_managed_accounts) }

  before do
    allow_next_instance_of(Gitlab::Auth::GroupSaml::SsoEnforcer) do |sso_enforcer|
      allow(sso_enforcer).to receive(:active_session?).and_return(true)
    end

    owner = managed_users.first
    group_with_managed_accounts.add_owner(owner)

    sign_in(owner)
  end

  describe 'GET #index' do
    let(:filter) {}
    let(:group_id) { group_with_managed_accounts.to_param }

    subject { get :index, params: { group_id: group_id.to_param, filter: filter } }

    context 'when `credentials_inventory` feature is enabled' do
      before do
        stub_licensed_features(credentials_inventory: true, group_saml: true)
      end

      context 'for a group that enforces group managed accounts' do
        context 'for a user with access to view credentials inventory' do
          it 'responds with 200' do
            subject

            expect(response).to have_gitlab_http_status(:ok)
          end

          context 'filtering by type of credential' do
            before do
              managed_users.each do |user|
                create(:personal_access_token, user: user)
              end
            end

            shared_examples_for 'filtering by `personal_access_tokens`' do
              it do
                subject

                expect(assigns(:credentials)).to match_array(PersonalAccessToken.where(user: managed_users))
              end
            end

            context 'no credential type specified' do
              let(:filter) { nil }

              it_behaves_like 'filtering by `personal_access_tokens`'
            end

            context 'non-existent credential type specified' do
              let(:filter) { 'non_existent_credential_type' }

              it_behaves_like 'filtering by `personal_access_tokens`'
            end

            context 'credential type specified as `personal_access_tokens`' do
              let(:filter) { 'personal_access_tokens' }

              it_behaves_like 'filtering by `personal_access_tokens`'
            end

            context 'user scope' do
              it 'does not show the credentials of a user outside the group' do
                personal_access_token = create(:personal_access_token, user: create(:user))

                subject

                expect(assigns(:credentials)).not_to include(personal_access_token)
              end
            end

            context 'credential type specified as `ssh_keys`' do
              let(:filter) { 'ssh_keys' }

              before do
                managed_users.each do |user|
                  create(:personal_key, user: user)
                end
              end

              it 'filters by ssh keys' do
                subject

                expect(assigns(:credentials)).to match_array(Key.regular_keys.where(user: managed_users))
              end
            end
          end

          context 'for a user without access to view credentials inventory' do
            before do
              maintainer = managed_users.last

              group_with_managed_accounts.add_maintainer(maintainer)

              sign_in(maintainer)
            end

            it 'responds with 404' do
              subject

              expect(response).to have_gitlab_http_status(:not_found)
            end
          end
        end
      end

      context 'for a group that does not enforce group managed accounts' do
        let(:group_id) { create(:group).to_param }

        it 'responds with 404' do
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
end
