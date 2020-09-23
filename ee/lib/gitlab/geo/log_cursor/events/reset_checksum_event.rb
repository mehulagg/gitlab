# frozen_string_literal: true

module Gitlab
  module Geo
    module LogCursor
      module Events
        class ResetChecksumEvent
          include BaseEvent

          def process
            registry.reset_checksum! unless skippable?

            log_event(
              'Reset checksum',
              project_id: event.project_id,
              skippable: skippable?)
          end
        end
      end
    end
  end
end
