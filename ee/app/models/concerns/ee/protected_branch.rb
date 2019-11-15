# frozen_string_literal: true

module EE
  module ProtectedBranch
    extend ActiveSupport::Concern

    prepended do
      protected_ref_access_levels :unprotect
    end

    class_methods do
      def branch_requires_code_owner_approval?(project, branch_name)
        return false unless project.code_owner_approval_required_available?

        project.protected_branches.requiring_code_owner_approval.matching(branch_name).any?
      end
    end

    def code_owner_approval_required
      super && project.code_owner_approval_required_available?
    end
    alias_method :code_owner_approval_required?, :code_owner_approval_required

    def can_unprotect?(user)
      return true if unprotect_access_levels.empty?

      unprotect_access_levels.any? do |access_level|
        access_level.check_access(user)
      end
    end
  end
end
