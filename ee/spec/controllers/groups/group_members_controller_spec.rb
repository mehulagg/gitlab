# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Groups::GroupMembersController do
  include ExternalAuthorizationServiceHelpers

  let_it_be(:user) { create(:user) }
  let_it_be(:group, reload: true) { create(:group, :public) }

  before do
    group.add_owner(user)
    sign_in(user)
  end

  describe 'GET #index' do
    context 'with members, invites and requests queries' do
      render_views

      let!(:invited) { create(:group_member, :invited, :developer, group: group) }
      let!(:requested) { create(:group_member, :access_request, group: group) }

      it 'records queries', :use_sql_query_cache do
        get :index, params: { group_id: group }

        control = ActiveRecord::QueryRecorder.new(skip_cached: false) { get :index, params: { group_id: group } }
        create_list(:group_member, 5, group: group, created_by: user)
        create_list(:group_member, 5, :invited, :developer, group: group, created_by: user)
        create_list(:group_member, 5, :access_request, group: group)
        # locally 47 vs 52
        unresolved_n_plus_ones = 4 # still have a few queries created by can_update/can_remove that should be reduced
        multiple_members_threshold = 1 # GDK vs CI difference

        expect do
          get :index, params: { group_id: group.reload }
        end.not_to exceed_all_query_limit(control.count).with_threshold(multiple_members_threshold + unresolved_n_plus_ones)
      end

      it 'avoids extra database queries utilizing pre-loading and use of any' do
        control = ActiveRecord::QueryRecorder.new { get :index, params: { group_id: group } }
        count_queries = control.occurrences_by_line_method.first[1][:occurrences].find_all { |i| i.include?('SELECT 1 AS one FROM') }

        expect(count_queries.count).to eq(3)
      end
    end
  end

  describe 'POST #create' do
    it 'creates an audit event' do
      expect do
        post :create, params: { group_id: group,
                                user_ids: user.id,
                                access_level: Gitlab::Access::GUEST }
      end.to change(AuditEvent, :count).by(1)
    end
  end

  describe 'DELETE #leave' do
    context 'when member is not an owner' do
      it 'creates an audit event' do
        developer = create(:user)
        group.add_developer(developer)
        sign_in(developer)

        expect { delete :leave, params: { group_id: group } }.to change(AuditEvent, :count).by(1)
      end
    end

    context 'when member is an owner' do
      it 'does not create an audit event' do
        expect { delete :leave, params: { group_id: group } }.not_to change(AuditEvent, :count)
      end
    end

    context 'when member requested access' do
      it 'creates an audit event' do
        requester = create(:user)
        group.request_access(requester)
        sign_in(requester)

        expect { delete :leave, params: { group_id: group } }.to change(AuditEvent, :count).by(1)
      end
    end
  end

  context 'with external authorization enabled' do
    before do
      enable_external_authorization_service_check
    end

    describe 'POST #override' do
      let_it_be(:group) { create(:group_with_ldap_group_link) }
      let_it_be(:membership) { create(:group_member, group: group) }

      before do
        allow(Ability).to receive(:allowed?).and_call_original
        allow(Ability).to receive(:allowed?).with(user, :override_group_member, membership) { true }
      end

      it 'is successful' do
        post :override,
             params: {
               group_id: group,
               id: membership,
               group_member: { override: true }
             },
             format: :js

        expect(response).to have_gitlab_http_status(:ok)
      end

      context 'when user has minimal access' do
        let_it_be(:membership) { create(:group_member, :minimal_access, source: group, user: create(:user)) }

        it 'is not successful' do
          post :override,
               params: {
                 group_id: group,
                 id: membership,
                 group_member: { override: true }
               },
               format: :js

          expect(response).to have_gitlab_http_status(:not_found)
        end

        context 'when minimal_access_role feature is available' do
          before do
            stub_licensed_features(minimal_access_role: true)
          end

          it 'is successful' do
            post :override,
                 params: {
                   group_id: group,
                   id: membership,
                   group_member: { override: true }
                 },
                 format: :js

            expect(response).to have_gitlab_http_status(:ok)
          end
        end
      end
    end
  end

  describe 'POST request_access' do
    before do
      create(:allowed_email_domain, group: group)
      sign_in(requesting_user)
    end

    shared_examples_for 'creates a new access request' do
      it 'creates a new access request to the group' do
        post :request_access, params: { group_id: group }

        expect(controller).to set_flash.to 'Your request for access has been queued for review.'
        expect(response).to redirect_to(group_path(group))
        expect(group.requesters.exists?(user_id: requesting_user)).to be_truthy
        expect(group.users).not_to include requesting_user
      end
    end

    shared_examples_for 'creates access request for a verified user with email belonging to the allowed domain' do
      context 'for a user with a verified email belonging to the allowed domain' do
        let(:email) { 'verified@gitlab.com' }
        let(:requesting_user) { create(:user, email: email, confirmed_at: Time.current) }

        it_behaves_like 'creates a new access request'
      end
    end

    context 'when users with unconfirmed emails are allowed to log-in' do
      before do
        stub_feature_flags(soft_email_confirmation: true)
      end

      context 'when group has email domain feature enabled' do
        before do
          stub_licensed_features(group_allowed_email_domains: true)
        end

        context 'for a user with an un-verified email belonging to the allowed domain' do
          let(:email) { 'unverified@gitlab.com' }
          let(:requesting_user) { create(:user, email: email, confirmed_at: nil) }

          it 'does not create a new access request' do
            post :request_access, params: { group_id: group }

            expect(controller).to set_flash.to "Your request for access could not be processed: "\
              "User email 'unverified@gitlab.com' is not a verified email."
            expect(response).to redirect_to(group_path(group))
            expect(group.requesters.exists?(user_id: requesting_user)).to be_falsey
            expect(group.users).not_to include requesting_user
          end
        end

        it_behaves_like 'creates access request for a verified user with email belonging to the allowed domain'
      end

      context 'when group has email domain feature disabled' do
        let_it_be(:email) { 'unverified@gitlab.com' }
        let_it_be(:requesting_user) { create(:user, email: email, confirmed_at: nil) }

        before do
          stub_licensed_features(group_allowed_email_domains: false)
        end

        context 'for a user with an un-verified email belonging to the allowed domain' do
          it_behaves_like 'creates a new access request'
        end

        context 'for a user with an un-verified email belonging to a domain different from the allowed domain' do
          let(:email) { 'unverified@gmail.com' }

          it_behaves_like 'creates a new access request'
        end

        it_behaves_like 'creates access request for a verified user with email belonging to the allowed domain'
      end
    end

    context 'when users with unconfirmed emails are not allowed to log-in' do
      before do
        stub_feature_flags(soft_email_confirmation: false)
      end

      shared_examples_for 'does not create a new access request due to user pending confirmation' do
        it 'does not create a new access request due to user pending confirmation' do
          post :request_access, params: { group_id: group }

          expect(response).to redirect_to(new_user_session_path)
          expect(controller).to set_flash.to I18n.t('devise.failure.unconfirmed')
          expect(group.requesters.exists?(user_id: requesting_user)).to be_falsey
          expect(group.users).not_to include requesting_user
        end
      end

      context 'when group has email domain feature enabled' do
        before do
          stub_licensed_features(group_allowed_email_domains: true)
        end

        context 'for a user with an un-verified email belonging to the allowed domain' do
          let(:email) { 'unverified@gitlab.com' }
          let(:requesting_user) { create(:user, email: email, confirmed_at: nil) }

          it_behaves_like 'does not create a new access request due to user pending confirmation'
        end

        it_behaves_like 'creates access request for a verified user with email belonging to the allowed domain'
      end

      context 'when group has email domain feature disabled' do
        let_it_be(:email) { 'unverified@gitlab.com' }
        let_it_be(:requesting_user) { create(:user, email: email, confirmed_at: nil) }

        before do
          stub_licensed_features(group_allowed_email_domains: false)
        end

        context 'for a user with an un-verified email belonging to the allowed domain' do
          it_behaves_like 'does not create a new access request due to user pending confirmation'
        end

        context 'for a user with an un-verified email belonging to a domain different from the allowed domain' do
          let(:email) { 'unverified@gmail.com' }

          it_behaves_like 'does not create a new access request due to user pending confirmation'
        end

        it_behaves_like 'creates access request for a verified user with email belonging to the allowed domain'
      end
    end
  end

  describe 'POST #resend_invite' do
    context 'when user has minimal access' do
      let_it_be(:membership) { create(:group_member, :minimal_access, source: group, user: create(:user)) }

      it 'is not successful' do
        post :resend_invite, params: { group_id: group, id: membership }

        expect(response).to have_gitlab_http_status(:not_found)
      end

      context 'when minimal_access_role feature is available' do
        before do
          stub_licensed_features(minimal_access_role: true)
        end

        it 'is successful' do
          post :resend_invite, params: { group_id: group, id: membership }

          expect(response).to have_gitlab_http_status(:found)
        end
      end
    end
  end
end
