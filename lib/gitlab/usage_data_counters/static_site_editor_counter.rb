# frozen_string_literal: true

module Gitlab
  module UsageDataCounters
    class StaticSiteEditorCounter < BaseCounter
      KNOWN_EVENTS = %w[views commits merge_requests].freeze
      PREFIX = 'static_site_editor'

      class << self
        def increment_views_count
          count(:views)
        end

        def increment_commits_count
          count(:commits)
        end

        def increment_merge_requests_count
          count(:merge_requests)
        end
      end
    end
  end
end
