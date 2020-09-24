# frozen_string_literal: true
class Groups::PushRulesController < Groups::ApplicationController
  include Gitlab::Utils::StrongMemoize
  include PushRulesHelper

  layout 'group'

  before_action :check_push_rules_available!
  before_action :push_rule

  respond_to :html

  def edit
  end

  def update
    if @push_rule.update(push_rule_params)
      flash[:notice] = _('Push Rule updated successfully.')
    else
      flash[:alert] = @push_rule.errors.full_messages.join(', ').html_safe
    end

    redirect_to edit_group_push_rules_path(group)
  end

  private

  def push_rule_params
    allowed_fields = %i[deny_delete_tag delete_branch_regex commit_message_regex commit_message_negative_regex
                        branch_name_regex force_push_regex author_email_regex
                        member_check file_name_regex max_file_size prevent_secrets]

    if can?(current_user, :change_reject_unsigned_commits, group)
      allowed_fields << :reject_unsigned_commits
    end

    if can?(current_user, :change_commit_committer_check, group)
      allowed_fields << :commit_committer_check
    end

    params.require(:push_rule).permit(allowed_fields)
  end

  def push_rule
    strong_memoize(:push_rule) do
      group.update(push_rule: PushRule.create!) unless group.push_rule
      group.push_rule
    end
  end

  def check_push_rules_available!
    render_404 unless can_modify_group_push_rules?(current_user, group)
  end
end
