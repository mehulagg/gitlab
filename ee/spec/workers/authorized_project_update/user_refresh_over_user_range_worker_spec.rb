# frozen_string_literal: true

require 'spec_helper'

RSpec.describe AuthorizedProjectUpdate::UserRefreshOverUserRangeWorker do
  let_it_be(:project) { create(:project) }

  let(:user) { project.namespace.owner }
  let(:start_user_id) { user.id }
  let(:end_user_id) { start_user_id }
  let(:execute_worker) { subject.perform(start_user_id, end_user_id) }

  describe '#perform' do
    context 'when the feature flag `periodic_project_authorization_update_via_replica` is disabled' do
      before do
        stub_feature_flags(periodic_project_authorization_update_via_replica: false)
      end

      context 'when load balancing is enabled' do
        before do
          allow(Gitlab::Database::LoadBalancing).to receive(:enable?).and_return(true)
        end

        it 'reads from the primary database' do
          expect(Gitlab::Database::LoadBalancing::Session.current)
            .to receive(:use_primary!)

          execute_worker
        end
      end
    end
  end
end
