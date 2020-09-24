# frozen_string_literal: true

module Elastic
  module Latest
    module Routing
      extend ActiveSupport::Concern

      ES_ROUTING_MAX_COUNT = 128

      def routing_options(options)
        return {} if options[:public_and_internal_projects]

        ids = if options[:project_id]
                [options[:project_id]]
              elsif options[:project_ids]
                options[:project_ids]
              elsif options[:repository_id]
                [options[:repository_id]]
              else
                []
              end

        return {} if ids == :any

        routing = build_routing(ids)

        return {} if routing.blank?

        { routing: routing }
      end

      private

      def build_routing(ids)
        return [] if ids.count > ES_ROUTING_MAX_COUNT

        ids.map { |id| "project_#{id}" }.join(',')
      end
    end
  end
end
