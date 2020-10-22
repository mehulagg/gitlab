# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Admin::EmailService do
  include ExclusiveLeaseHelpers

  describe '#execute', :clean_gitlab_redis_shared_state do
    let(:args) { %w(all email_subject email_body) }
    let(:lease_key) { 'admin/email_service' }

    subject { described_class.new(*args) }

    context 'when we can obtain the lease' do
      it 'schedules the worker' do
        stub_exclusive_lease(lease_key, timeout: described_class::DEFAULT_LEASE_TIMEOUT)

        expect(AdminEmailsWorker).to receive(:perform_async).with(*args).once

        subject.execute
      end
    end

    context "when we can't obtain the lease" do
      it 'does not schedule the worker' do
        stub_exclusive_lease_taken(lease_key, timeout: described_class::DEFAULT_LEASE_TIMEOUT)

        expect(AdminEmailsWorker).not_to receive(:perform_async)

        subject.execute
      end
    end
  end
end
