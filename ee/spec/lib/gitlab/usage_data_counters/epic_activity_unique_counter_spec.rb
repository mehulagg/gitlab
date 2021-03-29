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

  context 'for epic title changed event' do
    def track_action(params)
      described_class.track_epic_title_changed_action(**params)
    end

    it_behaves_like 'a daily tracked issuable event' do
      let(:action) { described_class::EPIC_TITLE_CHANGED }
    end

    it_behaves_like 'does not track when feature flag is disabled', :track_epics_activity
  end

  context 'for epic description changed event' do
    def track_action(params)
      described_class.track_epic_description_changed_action(**params)
    end

    it_behaves_like 'a daily tracked issuable event' do
      let(:action) { described_class::EPIC_DESCRIPTION_CHANGED }
    end

    it_behaves_like 'does not track when feature flag is disabled', :track_epics_activity
  end

  context 'for epic note created event' do
    def track_action(params)
      described_class.track_epic_note_created_action(**params)
    end

    it_behaves_like 'a daily tracked issuable event' do
      let(:action) { described_class::EPIC_NOTE_CREATED }
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
  end

  context 'for epic note destroyed event' do
    def track_action(params)
      described_class.track_epic_note_destroyed_action(**params)
    end

    it_behaves_like 'a daily tracked issuable event' do
      let(:action) { described_class::EPIC_NOTE_DESTROYED }
    end
  end

  context 'for epic closing event' do
    def track_action(params)
      described_class.track_epic_closed_action(**params)
    end

    it_behaves_like 'a daily tracked issuable event' do
      let(:action) { described_class::EPIC_CLOSED }
    end

    it_behaves_like 'does not track when feature flag is disabled', :track_epics_activity
  end

  context 'for epic reopening event' do
    def track_action(params)
      described_class.track_epic_reopened_action(**params)
    end

    it_behaves_like 'a daily tracked issuable event' do
      let(:action) { described_class::EPIC_REOPENED }
    end

    it_behaves_like 'does not track when feature flag is disabled', :track_epics_activity
  end

  context 'for epic date modification events' do
    context 'start date' do
      context 'setting as fixed event' do
        def track_action(params)
          described_class.track_epic_start_date_set_as_fixed_action(**params)
        end

        it_behaves_like 'a daily tracked issuable event' do
          let(:action) { described_class::EPIC_START_DATE_SET_AS_FIXED }
        end

        it_behaves_like 'does not track when feature flag is disabled', :track_epics_activity
      end

      context 'setting as inherited event' do
        def track_action(params)
          described_class.track_epic_start_date_set_as_inherited_action(**params)
        end

        it_behaves_like 'a daily tracked issuable event' do
          let(:action) { described_class::EPIC_START_DATE_SET_AS_INHERITED }
        end

        it_behaves_like 'does not track when feature flag is disabled', :track_epics_activity
      end
    end

    context 'due date' do
      context 'setting as fixed event' do
        def track_action(params)
          described_class.track_epic_due_date_set_as_fixed_action(**params)
        end

        it_behaves_like 'a daily tracked issuable event' do
          let(:action) { described_class::EPIC_DUE_DATE_SET_AS_FIXED }
        end

        it_behaves_like 'does not track when feature flag is disabled', :track_epics_activity
      end

      context 'setting as inherited event' do
        def track_action(params)
          described_class.track_epic_due_date_set_as_inherited_action(**params)
        end

        it_behaves_like 'a daily tracked issuable event' do
          let(:action) { described_class::EPIC_DUE_DATE_SET_AS_INHERITED }
        end

        it_behaves_like 'does not track when feature flag is disabled', :track_epics_activity
      end
    end
  end

  context 'for adding issue to epic event' do
    def track_action(params)
      described_class.track_epic_issue_added(**params)
    end

    it_behaves_like 'a daily tracked issuable event' do
      let(:action) { described_class::EPIC_ISSUE_ADDED }
    end

    it_behaves_like 'does not track when feature flag is disabled', :track_epics_activity
  end
end
