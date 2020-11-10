# frozen_string_literal: true

module Gitlab
  module UsageDataCounters
    COUNTERS = [
      WikiPageCounter,
      WebIdeCounter,
      NoteCounter,
      SnippetCounter,
      SearchCounter,
      CycleAnalyticsCounter,
      ProductivityAnalyticsCounter,
      SourceCodeCounter,
      MergeRequestCounter,
      DesignsCounter,
      KubernetesAgentCounter,
      StaticSiteEditorCounter
    ].freeze

    UsageDataCounterError = Class.new(StandardError)
    UnknownEvent = Class.new(UsageDataCounterError)

    class << self
      def counters
        self::COUNTERS
      end

      def count(event_name)
        counter = counters.find { |counter| counter.fetch_supported_event(event_name) }

        raise UnknownEvent, "Cannot find counter for event #{event_name}" unless counter

        counter.count(counter.fetch_supported_event(event_name))
      end
    end
  end
end
