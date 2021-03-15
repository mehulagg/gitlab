# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Geo::SecondaryUsageDataCronWorker, :clean_gitlab_redis_shared_state do
  include ::EE::GeoHelpers

  before do
    allow(subject).to receive(:try_obtain_lease).and_yield
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

  it 'calls SecondaryUsageData update metrics when it obtains the lease' do
    expect(subject).to receive(:try_obtain_lease).and_yield
    expect(Geo::SecondaryUsageData).to receive(:update_metrics!)

    subject.perform
  end

  it 'does not update metrics if secondary_usage_data_collection is disabled' do
    stub_feature_flag(:secondary_usage_data_collection, false)

    expect(subject).not_to receive(:try_obtain_lease)
    expect(Geo::SecondaryUsageData).to receive(:update_metrics!)

    subject.perform
  end

  it 'does not update metrics if it does not obtain the lease' do
    expect(subject).to receive(:try_obtain_lease).and_return(false)
    expect(Geo::SecondaryUsageData).not_to receive(:update_metrics!)

    subject.perform
  end
end
