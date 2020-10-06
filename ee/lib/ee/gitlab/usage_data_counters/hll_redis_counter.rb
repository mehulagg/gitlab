# frozen_string_literal: true

module EE
  module Gitlab
    module UsageDataCounters
      module HLLRedisCounter
        extend ActiveSupport::Concern
        class_methods do
          extend ::Gitlab::Utils::Override

          override :track_event
          def track_event(entity_id, event_name, time = Time.zone.now)
            # Rails.logger.info(" ----- EE::Event:: #{ event_name } #{ entity_id }")
            # Rails.logger.info(" ----- Plan : #{ License.current.plan }")
            super
          end
        end
      end
    end
  end
end
