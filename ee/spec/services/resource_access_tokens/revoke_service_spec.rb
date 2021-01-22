# frozen_string_literal: true

require 'spec_helper'

RSpec.describe ResourceAccessTokens::RevokeService do
  subject { described_class.new(user, resource, access_token).execute }

  let_it_be(:user) { create(:user) }
  let_it_be(:resource_bot) { create(:user, :project_bot) }
  let(:access_token) { create(:personal_access_token, user: resource_bot) }

  shared_examples 'audit event details' do
    it 'logs author and resource info', :aggregate_failures do
      expect { subject }.to change { AuditEvent.count }.from(0).to(1)
      expect(AuditEvent.last.author_id).to eq(user.id)
      expect(AuditEvent.last.entity_id).to eq(resource.id)
      expect(AuditEvent.last.ip_address).to eq(user.current_sign_in_ip)
    end
  end

  context 'project access token audit events' do
    let(:resource) { create(:project) }

    context 'when project access token is successfully revoked' do
      before do
        resource.add_maintainer(user)
        resource.add_maintainer(resource_bot)
      end

      it_behaves_like 'audit event details'

      it 'logs project access token details', :aggregate_failures do
        subject

        expect(AuditEvent.last.details[:custom_message]).to match(/Revoked project access token with id: \d+/)
        expect(AuditEvent.last.details[:target_details]).to eq(access_token.user.name)
      end
    end

    context 'when project access token is unsuccessfully revoked' do
      context 'when access token does not belong to this project' do
        before do
          resource.add_maintainer(user)
        end

        it_behaves_like 'audit event details'

        it 'logs the find error message' do
          subject

          expect(AuditEvent.last.details[:custom_message]).to match(/Attempted to revoke project access token with id: \d+, but failed with message: Failed to find bot user/)
        end
      end

      context 'with inadequate permissions' do
        before do
          resource.add_developer(user)
          resource.add_maintainer(resource_bot)
        end

        it_behaves_like 'audit event details'

        it 'logs the permission error message' do
          subject

          expect(AuditEvent.last.details[:custom_message]).to match(/Attempted to revoke project access token with id: \d+, but failed with message: #{user.name} cannot delete #{access_token.user.name}/)
        end
      end
    end
  end
end
