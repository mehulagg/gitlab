# frozen_string_literal: true

require 'spec_helper'

RSpec.describe ProjectFeatureUsage, :request_store do
  include_context 'clear DB Load Balancing configuration'

  describe '#log_jira_dvcs_integration_usage' do
    let!(:project) { create(:project) }

    subject { project.feature_usage }

    context 'database load balancing is configured' do
      before do
        # Do not pollute AR for other tests, but rather simulate effect of configure_proxy.
        allow(ActiveRecord::Base.singleton_class).to receive(:prepend)
        ::Gitlab::Database::LoadBalancing.configure_proxy
        allow(ActiveRecord::Base).to receive(:connection).and_return(::Gitlab::Database::LoadBalancing.proxy)
        ::Gitlab::Database::LoadBalancing::Session.clear_session
      end

      it 'logs Jira DVCS Cloud last sync' do
        freeze_time do
          subject.log_jira_dvcs_integration_usage

          expect(subject.jira_dvcs_server_last_sync_at).to be_nil
          expect(subject.jira_dvcs_cloud_last_sync_at).to be_like_time(Time.current)
        end
      end

      it 'does not stick to primary' do
        expect(::Gitlab::Database::LoadBalancing::Session.current).not_to be_performed_write
        expect(::Gitlab::Database::LoadBalancing::Session.current).not_to be_using_primary

        subject.log_jira_dvcs_integration_usage

        expect(::Gitlab::Database::LoadBalancing::Session.current).to be_performed_write
        expect(::Gitlab::Database::LoadBalancing::Session.current).not_to be_using_primary
      end
    end

    context 'database load balancing is not cofigured' do
      it 'logs Jira DVCS Cloud last sync' do
        freeze_time do
          subject.log_jira_dvcs_integration_usage

          expect(subject.jira_dvcs_server_last_sync_at).to be_nil
          expect(subject.jira_dvcs_cloud_last_sync_at).to be_like_time(Time.current)
        end
      end
    end
  end
end
