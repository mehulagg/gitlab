# frozen_string_literal: true

module Ci
  module JobTokenScope
    module EditScopeValidations
      ValidationError = Class.new(StandardError)

      def validate_edit!(source_project, target_project, current_user)
        unless source_project.ci_job_token_scope_enabled?
          raise ValidationError, "Edit not allowed since job token scope is disabled for this project"
        end

        unless can?(current_user, :admin_project, source_project)
          raise ValidationError, "Insufficient permissions to modify the job token scope"
        end

        unless target_project
          raise ValidationError, "Target project must be provided"
        end

        unless can?(current_user, :read_project, target_project)
          raise ValidationError, "Insufficient permissions to add the target project"
        end
      end
    end
  end
end
