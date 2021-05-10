# frozen_string_literal: true

module Gitlab
  module Checks
    class ChangeAccess
      ATTRIBUTES = %i[user_access project skip_authorization
                      skip_lfs_integrity_check protocol oldrev newrev ref
                      branch_name tag_name logger commits].freeze

      attr_reader(*ATTRIBUTES)

      def initialize(
        user_access:, project:, protocol:, logger:
      )
        @user_access = user_access
        @project = project
        @protocol = protocol
        @logger = logger
      end

      def validate_change!(oldrev, newrev, ref, skip_lfs_integrity_check: false)
        @logger.append_message("Running checks for ref: #{Gitlab::Git.branch_name(@ref) || Gitlab::Git.tag_name(@ref)}")

        ref_level_checks(oldrev, newrev, ref, skip_lfs_integrity_check: skip_lfs_integrity_check)
        # Check of commits should happen as the last step
        # given they're expensive in terms of performance
        commits_check(oldrev, newrev)

        true
      end

      def commits(newrev)
        @commits ||= {}
        @commits[newrev] ||= project.repository.new_commits(newrev)
      end

      protected

      def ref_level_checks(oldrev, newrev, ref, skip_lfs_integrity_check: false)
        Gitlab::Checks::PushCheck.new(self).validate_change!(oldrev, newrev, ref)
        Gitlab::Checks::BranchCheck.new(self).validate_change!(oldrev, newrev, ref)
        Gitlab::Checks::TagCheck.new(self).validate_change!(oldrev, newrev, ref)
        Gitlab::Checks::LfsCheck.new(self).validate_change!(oldrev, newrev, ref) unless skip_lfs_integrity_check
      end

      def commits_check(oldrev, newrev)
        Gitlab::Checks::DiffCheck.new(self).validate!(oldrev, newrev)
      end
    end
  end
end

Gitlab::Checks::ChangeAccess.prepend_if_ee('EE::Gitlab::Checks::ChangeAccess')
