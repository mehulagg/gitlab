# frozen_string_literal: true

module Gitlab
  module Geo
    module LogCursor
      module Events
        class ResetChecksumEvent
          include BaseEvent

          def process
            registry.reset_checksum! unless registry_exists?

            log_event(
              'Reset checksum',
              project_id: event.project_id,
              skippable: registry_exists?)
          end
        end
      end
    end
  end
end
