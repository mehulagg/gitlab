# frozen_string_literal: true

module Gitlab
  module UsageDataCounters
    class PackageUniqueCounter < HLLRedisCounter
      EVENT_SCOPES = (::Packages::Package.package_types.keys + [:container, :tag]).freeze

      EVENT_TYPES = {
        push_package: 0,
        delete_package: 1,
        pull_package: 2,
        search_package: 3,
        list_package: 4,
        list_repositories: 5,
        delete_repository: 6,
        delete_tag: 7,
        delete_tag_bulk: 8,
        list_tags: 9,
        cli_metadata: 10
      }.freeze

      ORIGINATOR_TYPES = { user: 0, deploy_token: 1 }.freeze

      protected

      def self.known_events
        @known_events ||= package_events.map(&:with_indifferent_access)
      end

      private

      def self.package_events
        events = []

        EVENT_SCOPES.each do |event_scope|
          EVENT_TYPES.keys.each do |event_type|
            ORIGINATOR_TYPES.keys.each do |originator_type|
              events << { name: "#{event_scope}_#{originator_type}_#{event_type}", category: "#{event_scope}_packages", aggregation: "daily" }
            end
          end
        end

        events
      end
    end
  end
end
