# frozen_string_literal: true

module Atlassian
  module JiraConnect
    module Serializers
      class BaseEntity < Grape::Entity
        include Gitlab::Routing
        include GitlabRoutingHelper

        format_with(:string) { |value| value.to_s }

        expose :monotonic_time, as: :updateSequenceId

        private

        def monotonic_time
          options[:update_sequence_id] || Client.generate_update_sequence_id
        end
      end
    end
  end
end
