# frozen_string_literal: true

require 'spec_helper'
require File.expand_path('ee/elastic/migrate/20210623081800_add_upvotes_to_issues.rb')

RSpec.describe AddUpvotesToIssues, :elastic, :sidekiq_inline do
  let(:version) { 20210623081800 }
  let(:migration) { described_class.new(version) }
  let(:helper) { Gitlab::Elastic::Helper.new }

  before do
    stub_ee_application_setting(elasticsearch_search: true, elasticsearch_indexing: true)
    allow(migration).to receive(:helper).and_return(helper)
  end

  describe 'migration_options' do
    it 'has migration options set', :aggregate_failures do
      expect(migration.batched?).to be_truthy
      expect(migration.throttle_delay).to eq(3.minutes)
    end
  end
end
