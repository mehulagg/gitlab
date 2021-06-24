# frozen_string_literal: true

require 'spec_helper'

RSpec.describe API::Invitations, 'EE Invitations' do
  include GroupAPIHelpers

  let_it_be(:group) { create(:group) }
  let_it_be(:admin) { create(:user, :admin, email: 'admin@example.com') }

  let(:invite_email) { 'restricted@example.org' }

  describe 'POST /groups/:id/invitations' do
    describe 'inviting a restricted email to group as admin' do
      shared_examples 'an error inviting an email address restricted for signup' do
        it 'returns an http error response and the validation message' do
          post api("/groups/#{group.id}/invitations", admin),
          params: { email: invite_email, access_level: Member::MAINTAINER }

          expect(response).to have_gitlab_http_status(:method_not_allowed)
          expect(json_response['message']).to eq "User is not from an allowed domain."
        end
      end

      context 'when restricted by admin signup restriction - denylist' do
        before do
          allow_next_instance_of(ApplicationSetting) do |instance|
            allow(instance).to receive(:domain_denylist).and_return(['example.org'])
          end
        end

        it_behaves_like 'an error inviting an email address restricted for signup'
      end

      context 'when restricted by admin signup restriction - allowlist' do
        before do
          stub_application_setting(domain_allowlist: ['example.com'])
        end

        it_behaves_like 'an error inviting an email address restricted for signup'
      end

      context 'when restricted by admin signup restriction - email restrictions' do
        before do
          stub_licensed_features(group_allowed_email_domains: true)

          create(:allowed_email_domain, group: group, domain: 'example.com')
        end

        it_behaves_like 'an error inviting an email address restricted for signup'
      end

      context 'when restricted by group settings' do
        # this response code should be changed to 4xx: https://gitlab.com/gitlab-org/gitlab/-/issues/321706
        it 'returns a success resopnse and the validation message' do
          post api("/groups/#{group.id}/invitations", admin),
          params: { email: invite_email, access_level: Member::MAINTAINER }

          expect(response).to have_gitlab_http_status(:success)
          expect(json_response['message']).to eq "Invite email email 'restricted@example.org' does not match the allowed domain of example.com"
        end
      end
    end
  end

  describe 'POST /projects/:id/invitations' do
    describe 'inviting a restricted email to project as admin' do
      let!(:project) { create(:project, namespace: group) }

      context 'when restricted by admin signup restrictions' do
        before do
          stub_application_setting(domain_allowlist: ['example.com'])
        end

        it 'returns an http error response and the validation message' do
          post api("/projects/#{project.id}/invitations", admin),
          params: { email: invite_email, access_level: Member::MAINTAINER }

          expect(response).to have_gitlab_http_status(:method_not_allowed)
          expect(json_response['message']).to eq "User is not from an allowed domain."
        end
      end

      context 'when restricted by group settings on the project\'s group' do
        # this response code should be changed to 4xx: https://gitlab.com/gitlab-org/gitlab/-/issues/321706
        it 'returns a success resopnse and the validation message' do
          post api("/projects/#{project.id}/invitations", admin),
          params: { email: invite_email, access_level: Member::MAINTAINER }

          expect(response).to have_gitlab_http_status(:success)
          expect(json_response['message']).to eq "Invite email email 'restricted@example.com' does not match the allowed domain of allowed-example.com"
        end
      end
    end
  end
end
