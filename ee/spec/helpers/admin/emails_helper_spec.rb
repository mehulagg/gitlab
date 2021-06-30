# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Admin::EmailsHelper, :clean_gitlab_redis_shared_state do
  include ExclusiveLeaseHelpers

  let(:lease_key) { Admin::EmailService::LEASE_KEY }
  let(:timeout) { Admin::EmailService::DEFAULT_LEASE_TIMEOUT }

  describe '#send_emails_from_admin_area_feature_available?' do
    subject { helper.send_emails_from_admin_area_feature_available? }

    context 'when `send_emails_from_admin_area` feature is enabled' do
      before do
        stub_licensed_features(send_emails_from_admin_area: true)
      end

      it { is_expected.to be_truthy }
    end

    context 'when `send_emails_from_admin_area` feature is disabled' do
      before do
        stub_licensed_features(send_emails_from_admin_area: false)
        stub_application_setting(usage_ping_enabled: false)
      end

      it { is_expected.to be_falsey }
    end

    context 'when usage ping is enabled' do
      before do
        stub_licensed_features(send_emails_from_admin_area: false)
        stub_application_setting(usage_ping_enabled: true)
      end

      context 'when feature is activated' do
        before do
          stub_application_setting(usage_ping_features_enabled: true)
        end

        it 'returns true' do
          expect(subject).to eq(true)
        end
      end

      context 'when feature is deactivated' do
        before do
          stub_application_setting(usage_ping_features_enabled: false)
        end

        it 'returns false' do
          expect(subject).to eq(false)
        end
      end
    end
  end

  describe '#admin_emails_are_currently_rate_limited?' do
    subject { helper.admin_emails_are_currently_rate_limited? }

    context 'when the lease key exists' do
      it 'returns true' do
        stub_exclusive_lease(lease_key, timeout: timeout)

        expect(subject).to eq(true)
      end
    end

    context 'when the lease key does not exist' do
      it 'returns false' do
        expect(subject).to eq(false)
      end
    end
  end

  describe '#admin_emails_rate_limit_ttl' do
    subject { helper.admin_emails_rate_limit_ttl }

    context 'when the lease key exists' do
      it 'returns the time remaining till the key expires' do
        stub_exclusive_lease(lease_key, timeout: timeout)

        expect(subject).to eq(timeout)
      end
    end

    context 'when the lease key does not exist' do
      it 'returns nil' do
        expect(subject).to be_nil
      end
    end
  end

  describe '#admin_emails_rate_limited_alert' do
    subject { helper.admin_emails_rate_limited_alert }

    context 'when the lease key exists' do
      it 'returns the alert' do
        stub_exclusive_lease(lease_key, timeout: timeout)

        expect(subject).to \
          eq('An email notification was recently sent from the admin panel. Please wait 10 minutes before attempting to send another message.')
      end
    end

    context 'when the lease key does not exist' do
      it 'returns empty string' do
        expect(subject).to eq('')
      end
    end
  end
end
