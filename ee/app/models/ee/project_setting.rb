# frozen_string_literal: true

module EE
  module ProjectSetting
    extend ActiveSupport::Concern

    prepended do
      belongs_to :push_rule

      scope :has_vulnerabilities, -> { where('has_vulnerabilities IS TRUE') }

      validate :allowed_to_edit_commits

      private

      def allowed_to_edit_commits
        return unless signed_commits_required?

        error_message = "Signed commits is required on this project, editing commit messges can't be enabled."
        errors.add(:allow_editing_commit_messages, error_message)
      end

      def signed_commits_required?
        return false unless push_rule

        push_rule.reject_unsigned_commits?
      end
    end
  end
end
