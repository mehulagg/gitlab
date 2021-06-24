# frozen_string_literal: true

module Gitlab
  module Search
    class RecentProjects < RecentItems
      private

      def type
        Project
      end

      def finder
        ProjectsFinder
      end
    end
  end
end
