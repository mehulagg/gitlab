# frozen_string_literal: true

class AddSettingsToGroupMergeRequestApprovalSettings < ActiveRecord::Migration[6.0]
  include Gitlab::Database::MigrationHelpers

  DOWNTIME = false

  def up
    with_lock_retries do
      add_column(
        :group_merge_request_approval_settings,
        :allow_committer_approval,
        :boolean,
        null: false,
        default: false
      )

      add_column(
        :group_merge_request_approval_settings,
        :allow_overrides_to_approver_list_per_merge_request,
        :boolean,
        null: false,
        default: false
      )

      add_column(
        :group_merge_request_approval_settings,
        :retain_approvals_on_push,
        :boolean,
        null: false,
        default: false
      )

      add_column(
        :group_merge_request_approval_settings,
        :require_password_to_approve,
        :boolean,
        null: false,
        default: false
      )
    end
  end

  def down
    with_lock_retries do
      remove_column :group_merge_request_approval_settings, :allow_committer_approval
      remove_column :group_merge_request_approval_settings, :allow_overrides_to_approver_list_per_merge_request
      remove_column :group_merge_request_approval_settings, :retain_approvals_on_push
      remove_column :group_merge_request_approval_settings, :require_password_to_approve
    end
  end
end
