# frozen_string_literal: true

module Gitlab
  module Ci
    module Status
      module Bridge
        class Play < Status::Build::Play
          def has_action?
            subject.can_run_by?(user)
          end

          def self.matches?(bridge, user)
            bridge.playable?
          end
        end
      end
    end
  end
end
