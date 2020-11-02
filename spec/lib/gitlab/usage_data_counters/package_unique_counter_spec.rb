# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Gitlab::UsageDataCounters::PackageUniqueCounter, :clean_gitlab_redis_shared_state do
  let(:entity1) { 'dfb9d2d2-f56c-4c77-8aeb-6cddc4a1f857' }
  let(:entity2) { '1dd9afb2-a3ee-4de1-8ae3-a405579c8584' }
  let(:entity3) { '34rfjuuy-ce56-sa35-ds34-dfer567dfrf2' }
  let(:entity4) { '8b9a2671-2abf-4bec-a682-22f6a8f7bf31' }

  around do |example|
    # We need to freeze to a reference time
    # because visits are grouped by the week number in the year
    # Without freezing the time, the test may behave inconsistently
    # depending on which day of the week test is run.
    # Monday 6th of June
    reference_time = Time.utc(2020, 6, 1)
    travel_to(reference_time) { example.run }
  end

  describe '.categories' do
    it 'gets all unique category names' do
      expect(described_class.categories).to contain_exactly(*described_class::EVENT_SCOPES.map { |scope| "#{scope}_packages" })
    end
  end

  describe 'unique_events_data' do
    subject { described_class.unique_events_data }

    before do
      described_class.track_event(entity1, 'composer_user_push_package', 2.days.ago)
      described_class.track_event(entity2, 'maven_deploy_token_delete_package', 2.days.ago)
    end

    it 'returns the number of unique events for all known events' do
      expect(subject).to include(*described_class.categories)

      expect(subject["composer_packages"]).to include("composer_user_push_package_monthly" => 1)
      expect(subject["composer_packages"]).to include("composer_user_delete_package_monthly" => 0)
      expect(subject["maven_packages"]).to include("maven_deploy_token_delete_package_monthly" => 1)
    end
  end
end
