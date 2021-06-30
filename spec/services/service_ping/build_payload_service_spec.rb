# frozen_string_literal: true

require 'spec_helper'

RSpec.describe ServicePing::BuildPayloadService do
  describe '#execute' do
    subject(:service_ping_payload) { described_class.new.execute }

    include_context 'stubbed service ping metrics definitions' do
      let(:subscription_metrics) do
        [
          metric_attributes('active_user_count', "Subscription")
        ]
      end
    end

    context 'GitLab instance does not have consented for required stats collection' do
      before do
        allow(User).to receive(:single_user).and_return(double(:user, requires_usage_stats_consent?: true))
      end

      it_behaves_like 'empty service ping payload'
    end

    context 'GitLab instance has consented for required stats collection' do
      before do
        allow(User).to receive(:single_user).and_return(double(:user, requires_usage_stats_consent?: false))
      end

      context 'GitLab instance does not have a license', :without_license do
        # License.current.present? == false
        context 'Instance consented to submit optional product intelligence data' do
          before do
            # Gitlab::CurrentSettings.usage_ping_enabled? == true
            stub_config_setting(usage_ping_enabled: true)
          end

          it_behaves_like 'complete service ping payload'
        end

        context 'Instance does NOT consented to submit optional product intelligence data' do
          before do
            # Gitlab::CurrentSettings.usage_ping_enabled? == false
            stub_config_setting(usage_ping_enabled: false)
          end

          it_behaves_like 'empty service ping payload'
        end
      end
    end
  end
end
