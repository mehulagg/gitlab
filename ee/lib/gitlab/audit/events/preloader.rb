# frozen_string_literal: true

module Gitlab
  module Audit
    module Events
      class Preloader
        def self.preload!(audit_events)
          audit_events.tap do |audit_events|
            audit_events.each do |audit_event|
              audit_event.lazy_author
              audit_event.lazy_entity
            end
          end
        end
      end
    end
  end
end
