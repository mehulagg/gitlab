# frozen_string_literal: true

module EE
  module Projects
    module GroupLinks
      module CreateService
        extend ::Gitlab::Utils::Override

        override :execute
        def execute(group)
          return error(error_message, 409) unless allowed_to_be_shared_with?(group)

          result = super

          log_audit_event(result[:link]) if result[:status] == :success
          result
        end

        private

        def allowed_to_be_shared_with?(group)
          project_can_be_shared_with_group = project_can_be_shared_with_group?(group, project)
          source_project_can_be_shared_with_group = project.forked? ? project_can_be_shared_with_group?(group, project.forked_from_project) : true

          project_can_be_shared_with_group && source_project_can_be_shared_with_group
        end

        def project_can_be_shared_with_group?(group, given_project)
          return true unless given_project.root_ancestor.kind == 'group' && given_project.root_ancestor.enforced_sso?

          group.root_ancestor == given_project.root_ancestor
        end

        def error_message
          _('This group cannot be invited to a project inside a group with enforced SSO')
        end

        def log_audit_event(group_link)
          ::AuditEventService.new(
            current_user,
            group_link.group,
            action: :create
          ).for_project_group_link(group_link).security_event
        end
      end
    end
  end
end
