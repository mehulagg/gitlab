# frozen_string_literal: true

module Gitlab
  module Audit
    module Levels
      class Project
        def initialize(project:)
          @project = project
        end

        def apply
          AuditEvent.by_entity('Project', @project)
        end
      end
    end
  end
end
