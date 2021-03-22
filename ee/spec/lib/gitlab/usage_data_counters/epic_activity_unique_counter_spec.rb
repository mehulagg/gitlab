# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Gitlab::UsageDataCounters::EpicActivityUniqueCounter, :clean_gitlab_redis_shared_state do
  let(:user1) { build(:user, id: 1) }
  let(:user2) { build(:user, id: 2) }
  let(:user3) { build(:user, id: 3) }
  let(:time) { Time.zone.now }

  context 'for epic created event' do
    def track_action(params)
      described_class.track_epic_created_action(**params)
    end

    it_behaves_like 'a daily tracked issuable event' do
      let(:action) { described_class::EPIC_CREATED }
    end

    it_behaves_like 'does not track when feature flag is disabled', :track_epics_activity
  end

  context 'for epic note updated event' do
    def track_action(params)
      described_class.track_epic_note_updated_action(**params)
    end

    it_behaves_like 'a daily tracked issuable event' do
      let(:action) { described_class::EPIC_NOTE_UPDATED }
    end

    it_behaves_like 'does not track when feature flag is disabled', :track_epics_activity
  end

  context 'for epic note destroyed event' do
    def track_action(params)
      described_class.track_epic_note_destroyed_action(**params)
    end

    it_behaves_like 'a daily tracked issuable event' do
      let(:action) { described_class::EPIC_NOTE_DESTROYED }
    end

    it_behaves_like 'does not track when feature flag is disabled', :track_epics_activity
  end

  context 'for epic date modification events' do
    context 'setting start date as fixed event' do
      def track_action(params)
        described_class.track_epic_start_date_set_as_fixed_action(**params)
      end

      it_behaves_like 'a daily tracked issuable event' do
        let(:action) { described_class::EPIC_START_DATE_SET_AS_FIXED }
      end

      it_behaves_like 'does not track when feature flag is disabled', :track_epics_activity
    end

    context 'setting start date as inherited event' do
      def track_action(params)
        described_class.track_epic_start_date_set_as_inherited_action(**params)
      end

      it_behaves_like 'a daily tracked issuable event' do
        let(:action) { described_class::EPIC_START_DATE_SET_AS_INHERITED }
      end

      it_behaves_like 'does not track when feature flag is disabled', :track_epics_activity
    end
  end
end
