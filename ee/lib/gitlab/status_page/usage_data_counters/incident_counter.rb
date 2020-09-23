# frozen_string_literal: true

module Gitlab
  module StatusPage
    module UsageDataCounters
      class IncidentCounter < ::Gitlab::UsageDataCounters::BaseCounter
        KNOWN_EVENTS = %w[publishes unpublishes].freeze
        PREFIX = 'status_page_incident'
      end
    end
  end
end
