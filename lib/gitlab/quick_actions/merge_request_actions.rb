# frozen_string_literal: true

module Gitlab
  module QuickActions
    module MergeRequestActions
      include Gitlab::QuickActions::Dsl

      helpers ::Gitlab::QuickActions::MergeRequestHelpers

      # MergeRequest only quick actions definitions
      desc do
        if Feature.enabled?(:merge_orchestration_service, quick_action_target.project, default_enabled: true)
          if preferred_strategy = preferred_auto_merge_strategy(quick_action_target)
            _("Merge automatically (%{strategy})") % { strategy: preferred_strategy.humanize }
          else
            _("Merge immediately")
          end
        else
          _('Merge (when the pipeline succeeds)')
        end
      end
      explanation do
        if Feature.enabled?(:merge_orchestration_service, quick_action_target.project, default_enabled: true)
          if preferred_strategy = preferred_auto_merge_strategy(quick_action_target)
            _("Schedules to merge this merge request (%{strategy}).") % { strategy: preferred_strategy.humanize }
          else
            _('Merges this merge request immediately.')
          end
        else
          _('Merges this merge request when the pipeline succeeds.')
        end
      end
      execution_message do
        if Feature.enabled?(:merge_orchestration_service, quick_action_target.project, default_enabled: true)
          if preferred_strategy = preferred_auto_merge_strategy(quick_action_target)
            _("Scheduled to merge this merge request (%{strategy}).") % { strategy: preferred_strategy.humanize }
          else
            _('Merged this merge request.')
          end
        else
          _('Scheduled to merge this merge request when the pipeline succeeds.')
        end
      end
      types MergeRequest
      condition do
        if Feature.enabled?(:merge_orchestration_service, quick_action_target.project, default_enabled: true)
          mergeable? &&
            merge_orchestration_service.can_merge?(quick_action_target)
        else
          last_diff_sha = params[:merge_request_diff_head_sha]
          mergeable? &&
            quick_action_target.mergeable_with_quick_action?(current_user, autocomplete_precheck: !last_diff_sha, last_diff_sha: last_diff_sha)
        end
      end
      command :merge do
        update(merge: params[:merge_request_diff_head_sha])
      end

      desc 'Toggle the Work In Progress status'
      explanation do
        noun = quick_action_target.to_ability_name.humanize(capitalize: false)
        if quick_action_target.work_in_progress?
          _("Unmarks this %{noun} as Work In Progress.")
        else
          _("Marks this %{noun} as Work In Progress.")
        end % { noun: noun }
      end
      execution_message do
        noun = quick_action_target.to_ability_name.humanize(capitalize: false)
        if quick_action_target.work_in_progress?
          _("Unmarked this %{noun} as Work In Progress.")
        else
          _("Marked this %{noun} as Work In Progress.")
        end % { noun: noun }
      end

      types MergeRequest
      condition do
        quick_action_target.respond_to?(:work_in_progress?) &&
          # Allow it to mark as WIP on MR creation page _or_ through MR notes.
          (quick_action_target.new_record? || current_user.can?(:"update_#{quick_action_target.to_ability_name}", quick_action_target))
      end
      command :wip do
        update(wip_event: quick_action_target.work_in_progress? ? 'unwip' : 'wip')
      end

      desc _('Set target branch')
      explanation do |branch_name|
        _('Sets target branch to %{branch_name}.') % { branch_name: branch_name }
      end
      execution_message do |branch_name|
        if project.repository.branch_exists?(branch_name)
          _('Set target branch to %{branch_name}.') % { branch_name: branch_name }
        end
      end
      params '<Local branch name>'
      types MergeRequest
      condition do
        quick_action_target.respond_to?(:target_branch) &&
          (current_user.can?(:"update_#{quick_action_target.to_ability_name}", quick_action_target) ||
            quick_action_target.new_record?)
      end
      parse_params do |target_branch_param|
        target_branch_param.strip
      end
      command :target_branch do |branch_name|
        if project.repository.branch_exists?(branch_name)
          update(target_branch: branch_name)
        else
          warn _('No branch named %{branch_name}.') % { branch_name: branch_name }
        end
      end

      desc _('Submit a review')
      explanation _('Submit the current review.')
      types MergeRequest
      condition do
        quick_action_target.persisted?
      end
      command :submit_review do
        next if params[:review_id]

        result = DraftNotes::PublishService.new(quick_action_target, current_user).execute
        if result[:status] == :success
          info _('Submitted the current review.')
        else
          warn result[:message]
        end
      end
    end
  end
end
