# frozen_string_literal: true

module EE
  module MergeRequest
    extend ActiveSupport::Concern
    extend ::Gitlab::Utils::Override

    include ::Approvable
    include ::Gitlab::Utils::StrongMemoize
    include FromUnion
    prepend ApprovableForRule

    prepended do
      include Elastic::MergeRequestsSearch

      has_many :reviews, inverse_of: :merge_request
      has_many :approvals, dependent: :delete_all # rubocop:disable Cop/ActiveRecordDependent
      has_many :approved_by_users, through: :approvals, source: :user
      has_many :approvers, as: :target, dependent: :delete_all # rubocop:disable Cop/ActiveRecordDependent
      has_many :approver_users, through: :approvers, source: :user
      has_many :approver_groups, as: :target, dependent: :delete_all # rubocop:disable Cop/ActiveRecordDependent
      has_many :approval_rules, class_name: 'ApprovalMergeRequestRule', inverse_of: :merge_request
      has_many :draft_notes

      validate :validate_approval_rule_source

      delegate :sha, to: :head_pipeline, prefix: :head_pipeline, allow_nil: true
      delegate :sha, to: :base_pipeline, prefix: :base_pipeline, allow_nil: true
      delegate :merge_requests_author_approval?, to: :target_project, allow_nil: true

      participant :participant_approvers

      accepts_nested_attributes_for :approval_rules, allow_destroy: true
    end

    class_methods do
      def select_from_union(relations)
        where(id: from_union(relations))
      end
    end

    override :mergeable?
    def mergeable?(skip_ci_check: false)
      return false unless approved?

      super
    end

    override :mergeable_ci_state?
    def mergeable_ci_state?
      return false unless validate_merge_request_pipelines

      super
    end

    def allows_multiple_assignees?
      project.multiple_mr_assignees_enabled? &&
        project.feature_available?(:multiple_merge_request_assignees)
    end

    def supports_weight?
      false
    end

    def validate_merge_request_pipelines
      return true unless project.merge_pipelines_enabled?

      actual_head_pipeline&.latest_merge_request_pipeline?
    end

    def validate_approval_rule_source
      return if ::Feature.disabled?(:approval_rules, project, default_enabled: true)
      return unless approval_rules.any?

      local_project_rule_ids = approval_rules.map { |rule| rule.approval_merge_request_rule_source&.approval_project_rule_id }
      local_project_rule_ids.compact!

      invalid = if new_record?
                  local_project_rule_ids.to_set != project.approval_rule_ids.to_set
                else
                  (local_project_rule_ids - project.approval_rule_ids).present?
                end

      errors.add(:approval_rules, :invalid_sourcing_to_project_rules) if invalid
    end

    def participant_approvers
      strong_memoize(:participant_approvers) do
        next [] unless approval_needed?

        if ::Feature.enabled?(:approval_rules, project, default_enabled: true)
          approval_state.filtered_approvers(code_owner: false, unactioned: true)
        else
          approvers = [
            *overall_approvers(exclude_code_owners: true),
            *approvers_from_groups
          ]

          ::User.where(id: approvers.map(&:id)).where.not(id: approved_by_users.select(:id))
        end
      end
    end

    def code_owners
      strong_memoize(:code_owners) do
        ::Gitlab::CodeOwners.for_merge_request(self).freeze
      end
    end

    def has_license_management_reports?
      actual_head_pipeline&.has_reports?(::Ci::JobArtifact.license_management_reports)
    end

    def compare_license_management_reports
      unless has_license_management_reports?
        return { status: :error, status_reason: 'This merge request does not have license management reports' }
      end

      compare_reports(::Ci::CompareLicenseManagementReportsService)
    end

    def has_metrics_reports?
      actual_head_pipeline&.has_reports?(::Ci::JobArtifact.metrics_reports)
    end

    def compare_metrics_reports
      unless has_metrics_reports?
        return { status: :error, status_reason: 'This merge request does not have metrics reports' }
      end

      compare_reports(::Ci::CompareMetricsReportsService)
    end

    def sync_code_owners_with_approvers
      return if merged?

      owners = code_owners

      if owners.present?
        ApplicationRecord.transaction do
          rule = approval_rules.code_owner.first
          rule ||= approval_rules.code_owner.create!(name: ApprovalMergeRequestRule::DEFAULT_NAME_FOR_CODE_OWNER)

          rule.users = owners.uniq
        end
      else
        approval_rules.code_owner.delete_all
      end
    end
  end
end
