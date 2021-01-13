# frozen_string_literal: true

module EE
  module ProjectSetting
    extend ActiveSupport::Concern

    prepended do
      belongs_to :push_rule

      scope :has_vulnerabilities, -> { where('has_vulnerabilities IS TRUE') }

      validate :allow_editing_commits

      private

      def allow_editing_commits
        return unless signed_commits_required?

        error_message = _("can't be enabled because signed commits are required for this project")
        errors.add(:allow_editing_commit_messages, error_message)
      end

      def signed_commits_required?
        return false unless push_rule

        push_rule.reject_unsigned_commits?
      end
    end
  end
end
