# frozen_string_literal: true

require 'spec_helper'

describe API::Members do
  let(:group) { create(:group) }
  let(:owner) { create(:user) }
  let(:project) { create(:project, group: group) }

  before do
    group.add_owner(owner)
  end

  describe 'POST /projects/:id/members' do
    context 'group membership locked' do
      let(:user) { create(:user) }
      let(:group) { create(:group, membership_lock: true)}
      let(:project) { create(:project, group: group) }

      context 'project in a group' do
        it 'returns a 405 method not allowed error when group membership lock is enabled' do
          post api("/projects/#{project.id}/members", owner),
               params: { user_id: user.id, access_level: Member::MAINTAINER }

          expect(response.status).to eq 405
        end
      end
    end
  end

  describe 'GET /groups/:id/members' do
    it 'matches json schema' do
      get api("/groups/#{group.to_param}/members", owner)

      expect(response).to have_gitlab_http_status(:ok)
      expect(response).to match_response_schema('public_api/v4/members')
    end

    context 'when a group has SAML provider configured' do
      let(:maintainer) { create(:user) }

      before do
        saml_provider = create :saml_provider, group: group
        create :group_saml_identity, user: owner, saml_provider: saml_provider

        group.add_maintainer(maintainer)
      end

      context 'and current_user is group owner' do
        it 'returns a list of users with group SAML identities info' do
          get api("/groups/#{group.to_param}/members", owner)

          expect(response).to have_gitlab_http_status(:ok)
          expect(json_response.size).to eq(2)
          expect(json_response.first['group_saml_identity']).to match(kind_of(Hash))
        end

        it 'allows to filter by linked identity presence' do
          get api("/groups/#{group.to_param}/members?with_saml_identity=true", owner)

          expect(response).to have_gitlab_http_status(:ok)
          expect(json_response.size).to eq(1)
          expect(json_response.any? { |member| member['id'] == maintainer.id }).to be_falsey
        end
      end

      context 'and current_user is not an owner' do
        it 'returns a list of users without group SAML identities info' do
          get api("/groups/#{group.to_param}/members", maintainer)

          expect(response).to have_gitlab_http_status(:ok)
          expect(json_response.map(&:keys).flatten).not_to include('group_saml_identity')
        end

        it 'ignores filter by linked identity presence' do
          get api("/groups/#{group.to_param}/members?with_saml_identity=true", maintainer)

          expect(response).to have_gitlab_http_status(:ok)
          expect(json_response.size).to eq(2)
          expect(json_response.any? { |member| member['id'] == maintainer.id }).to be_truthy
        end
      end
    end

    context 'with is_using_seat' do
      shared_examples 'seat information not included' do
        it 'returns a list of users that does not contain the is_using_seat attribute' do
          get api(api_url, owner)

          expect(response).to have_gitlab_http_status(:ok)
          expect(json_response.size).to eq(1)
          expect(json_response.first.keys).not_to include('is_using_seat')
        end
      end

      context 'with show_seat_info set to true' do
        it 'returns a list of users that contains the is_using_seat attribute' do
          get api("/groups/#{group.to_param}/members?show_seat_info=true", owner)

          expect(response).to have_gitlab_http_status(:ok)
          expect(json_response.size).to eq(1)
          expect(json_response.first['is_using_seat']).to be_truthy
        end
      end

      context 'with show_seat_info set to false' do
        let(:api_url) { "/groups/#{group.to_param}/members?show_seat_info=false" }

        it_behaves_like 'seat information not included'
      end

      context 'with no show_seat_info set' do
        let(:api_url) { "/groups/#{group.to_param}/members" }

        it_behaves_like 'seat information not included'
      end
    end
  end

  shared_examples 'POST /:source_type/:id/members' do |source_type|
    let(:stranger) { create(:user) }
    let(:url) { "/#{source_type.pluralize}/#{source.id}/members" }
    let(:post_params) { { user_id: stranger.id, access_level: Member::DEVELOPER } }

    context "with :source_type == #{source_type.pluralize}" do
      it 'creates an audit event while creating a new member' do
        expect do
          post api(url, owner), params: post_params

          expect(response).to have_gitlab_http_status(:created)
        end.to change { AuditEvent.count }.by(1)
      end

      it 'does not create audit event if creating a new member fails' do
        expect do
          post api(url, owner), params: post_params.merge(user_id: 0)

          expect(response).to have_gitlab_http_status(:not_found)
        end.not_to change { AuditEvent.count }
      end

      it 'updates the max_seats_used counter for subscription' do
        allow(Gitlab::CurrentSettings.current_application_settings)
          .to receive(:should_check_namespace_plan?) { true }

        expect { post api(url, owner), params: post_params }
          .to change { gitlab_subscription.reload.max_seats_used }.to(2)
      end
    end
  end

  it_behaves_like 'POST /:source_type/:id/members', 'project' do
    let(:source) { project }
    let!(:gitlab_subscription) { create(:gitlab_subscription, namespace: project.namespace) }
  end

  it_behaves_like 'POST /:source_type/:id/members', 'group' do
    let(:source) { group }
    let!(:gitlab_subscription) { create(:gitlab_subscription, namespace: group) }
  end
end
