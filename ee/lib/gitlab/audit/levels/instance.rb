# frozen_string_literal: true

module Gitlab
  module Audit
    module Levels
      class Instance
        def apply
          AuditEvent.all
        end
      end
    end
  end
end
