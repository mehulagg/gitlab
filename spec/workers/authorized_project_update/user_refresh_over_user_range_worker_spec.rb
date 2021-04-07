# frozen_string_literal: true

require 'spec_helper'

RSpec.describe AuthorizedProjectUpdate::UserRefreshOverUserRangeWorker do
  let(:project) { create(:project) }
  let(:user) { project.namespace.owner }
  let(:start_user_id) { user.id }
  let(:end_user_id) { start_user_id }
  let(:execute_service) { subject.perform(start_user_id, end_user_id) }

  it_behaves_like 'worker with data consistency',
                  described_class,
                  feature_flag: :periodic_project_authorization_update_via_replica,
                  data_consistency: :delayed

  describe '#perform' do
    context 'checks if project authorization update is required' do
      it 'checks if a project_authorization refresh is needed for each of the users' do
        User.where(id: start_user_id..end_user_id).select(:id).each do |user|
          expect(AuthorizedProjectUpdate::FindRecordsDueForRefreshService).to(
            receive(:new).with(user).and_call_original)
        end

        execute_service
      end
    end

    context 'when there are project authorization records due for either removal or addition for a specific user' do
      before do
        user.project_authorizations.delete_all
      end

      it 'enqueues a new project authorization update job for the user' do
        expect(AuthorizedProjectUpdate::UserRefreshWithLowUrgencyWorker).to receive(:perform_async).with(user.id)

        execute_service
      end

      it 'changes project authorizations of the user', :sidekiq_inline do
        expect { execute_service }.to change { user.reload.project_authorizations }
      end
    end

    context 'when there are no additions or removals to be made to project authorizations for a specific user' do
      it 'does not enqueue a new project authorization update job for the user' do
        expect(AuthorizedProjectUpdate::UserRefreshWithLowUrgencyWorker).not_to receive(:perform_async)

        execute_service
      end
    end
  end
end
