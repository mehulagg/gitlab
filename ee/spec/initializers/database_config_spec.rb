# frozen_string_literal: true

require 'spec_helper'

RSpec.describe 'Database config initializer for GitLab EE' do
  subject do
    load Rails.root.join('config/initializers/database_config.rb')
  end

  let(:max_threads) { 8 }

  before do
    skip "CI Vertical: not yet supported"

    allow(Gitlab::Runtime).to receive(:max_threads).and_return(max_threads)
    allow(ActiveRecord::Base).to receive(:establish_connection)

    expect(Geo::TrackingBase).to receive(:establish_connection)
  end

  context "and the runtime is Sidekiq" do
    before do
      stub_geo_database_config(pool_size: 1)
      allow(Gitlab::Runtime).to receive(:sidekiq?).and_return(true)
    end

    it "sets Geo DB connection pool size to the max number of worker threads" do
      expect { subject }.to change { Rails.configuration.geo_database['pool'] }.from(1).to(18)
    end
  end

  def stub_geo_database_config(pool_size:)
    config = {
      'adapter' => 'postgresql',
      'host' => 'db.host.com',
      'pool' => pool_size
    }.compact

    allow(Rails.configuration).to receive(:geo_database).and_return(config)
  end
end
