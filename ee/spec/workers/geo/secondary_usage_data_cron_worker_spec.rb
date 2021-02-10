# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Geo::SecondaryUsageDataCronWorker, :clean_gitlab_redis_shared_state do
  include ::EE::GeoHelpers

  before do
    allow(subject).to receive(:sleep)
    allow(Geo::SecondaryUsageData).to receive(:update_metrics!)
    stub_secondary_node
  end

  it 'uses a cronjob queue' do
    expect(subject.sidekiq_options_hash).to include(
      'queue' => 'cronjob:geo_secondary_usage_data_cron',
      'queue_namespace' => :cronjob
    )
  end

  it 'does not run for primary nodes' do
    allow(Gitlab::Geo).to receive(:secondary?).and_return(false)
    expect(Geo::SecondaryUsageData).not_to receive(:update_metrics!)

    subject.perform
  end

  it 'calls SecondaryUsageData update metrics' do
    expect(Geo::SecondaryUsageData).to receive(:update_metrics!)

    subject.perform
  end

  it "obtains a #{described_class::LEASE_TIMEOUT} second exclusive lease" do
    expect(Gitlab::ExclusiveLeaseHelpers::SleepingLock)
      .to receive(:new)
      .with(described_class::LEASE_KEY, hash_including(timeout: described_class::LEASE_TIMEOUT))
      .and_call_original

    subject.perform
  end

  it 'sleeps for between 0 and 60 seconds' do
    expect(subject).to receive(:sleep).with(0..60)

    subject.perform
  end

  context 'when lease is not obtained' do
    before do
      Gitlab::ExclusiveLease.new(described_class::LEASE_KEY, timeout: described_class::LEASE_TIMEOUT).try_obtain
    end

    it 'does not invoke SubmitUsagePingService' do
      expect(Geo::SecondaryUsageData).not_to receive(:update_metrics!)

      expect { subject.perform }.to raise_error(Gitlab::ExclusiveLeaseHelpers::FailedToObtainLockError)
    end
  end
end
