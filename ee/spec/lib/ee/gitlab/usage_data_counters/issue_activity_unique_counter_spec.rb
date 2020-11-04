# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Gitlab::UsageDataCounters::IssueActivityUniqueCounter, :clean_gitlab_redis_shared_state do
  let(:user1) { build(:user, id: 1) }
  let(:user2) { build(:user, id: 2) }
  let(:user3) { build(:user, id: 3) }
  let(:time) { Time.zone.now }

  context 'for Issue health status changed actions' do
    it_behaves_like 'a tracked issue edit event' do
      let(:action) { described_class::ISSUE_HEALTH_STATUS_CHANGED }

      def track_action(params)
        described_class.track_issue_health_status_changed_action(**params)
      end
    end
  end
end
