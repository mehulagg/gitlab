# frozen_string_literal: true

module EE
  module Projects
    module ProtectDefaultBranchService
      extend ::Gitlab::Utils::Override

      override :protect_branch?
      def protect_branch?
        return true if security_policy_project?

        super
      end

      # rubocop: disable CodeReuse/ActiveRecord
      def security_policy_project?
        ::Security::OrchestrationPolicyConfiguration.exists?(security_policy_management_project_id: project.id)
      end
      # rubocop: enable CodeReuse/ActiveRecord

      override :push_access_level
      def push_access_level
        return ::Gitlab::Access::NO_ACCESS if security_policy_project?

        super
      end

      override :merge_access_level
      def merge_access_level
        return ::Gitlab::Access::MAINTAINER if security_policy_project?

        super
      end
    end
  end
end
