# frozen_string_literal: true

require 'spec_helper'

RSpec.describe AuthorizedProjectUpdate::RefreshProjectAuthorizationsService do
  include ExclusiveLeaseHelpers

  let_it_be(:project) { create(:project) }

  subject(:service) { described_class.new(project) }

  describe '#execute', :clean_gitlab_redis_shared_state do
    it 'refreshes the authorizations of the project using a lease' do
      lease_key = "refresh_project_authorizations:#{project.id}"

      expect_to_obtain_exclusive_lease(lease_key, 'uuid')
      expect_to_cancel_exclusive_lease(lease_key, 'uuid')
      expect(service).to receive(:execute_without_lease)

      service.execute
    end
  end

  describe '#execute_without_lease' do
    subject(:execute_without_lease) { service.execute_without_lease }

    it 'returns success' do
      expect(execute_without_lease.success?).to eq(true)
    end

    context 'when there are no changes to be made' do
      it 'does not change authorizations' do
        expect { execute_without_lease }.not_to(change { ProjectAuthorization.count })
      end
    end

    context 'when there are changes to be made' do
      let(:user) { create(:user) }

      context 'when addition is required' do
        before do
          project.add_developer(user)
          project.project_authorizations.where(user: user).delete_all
        end

        it 'adds a new authorization record' do
          expect { execute_without_lease }.to(
            change { project.project_authorizations.where(user: user).count }
            .from(0).to(1)
          )
        end

        it 'adds a new authorization record with the correct access level' do
          execute_without_lease

          project_authorization = project.project_authorizations.where(
            user: user,
            access_level: Gitlab::Access::DEVELOPER
          )

          expect(project_authorization).to exist
        end
      end

      context 'when removal is required' do
        before do
          project.add_developer(user)
          project.members.where(user: user).delete_all
        end

        it 'removes the authorization record' do
          expect { execute_without_lease }.to(
            change { project.project_authorizations.where(user: user).count }
            .from(1).to(0)
          )
        end
      end

      context 'when an update in access level is required' do
        before do
          project.add_developer(user)
          project.project_authorizations.where(user: user).delete_all
          create(:project_authorization, project: project, user: user, access_level: Gitlab::Access::GUEST)
        end

        it 'updates the authorization of the user to the correct access level' do
          expect { execute_without_lease }.to(
            change { project.project_authorizations.find_by(user: user).access_level }
              .from(Gitlab::Access::GUEST).to(Gitlab::Access::DEVELOPER)
          )
        end
      end
    end
  end
end
