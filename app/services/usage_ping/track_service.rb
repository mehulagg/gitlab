# frozen_string_literal: true

module UsagePing
  class TrackService < ::BaseContainerService
    SUPPORTED_EVENTS = {
      'static_site_editor_commit' => -> { Gitlab::UsageDataCounters::StaticSiteEditorCounter.increment_commits_count },
      'static_site_editor_merge_request' => -> { Gitlab::UsageDataCounters::StaticSiteEditorCounter.increment_merge_requests_count }
    }

    def execute
      track_event!

      ServiceResponse.success
    rescue KeyError => e
      ServiceResponse.error(message: 'Unsupported event')
    end

    private

    def track_event!
      SUPPORTED_EVENTS.fetch(container).call
    end
  end
end
