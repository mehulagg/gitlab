# frozen_string_literal: true

module Gitlab
  module Audit
    module Events
      class Preloader
        def initialize(audit_events)
          @audit_events = audit_events
        end

        def find_each(&block)
          @audit_events.find_each do |audit_event|
            audit_event.lazy_author
            audit_event.lazy_entity

            block.call(audit_event)
          end
        end
      end
    end
  end
end
