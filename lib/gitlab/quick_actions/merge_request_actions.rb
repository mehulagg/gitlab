# frozen_string_literal: true

module Gitlab
  module QuickActions
    module MergeRequestActions
      extend ActiveSupport::Concern
      include Gitlab::QuickActions::Dsl

      included do
        # MergeRequest only quick actions definitions
        desc _('Merge (when the pipeline succeeds)')
        explanation _('Merges this merge request when the pipeline succeeds.')
        execution_message _('Scheduled to merge this merge request when the pipeline succeeds.')
        types MergeRequest
        condition do
          last_diff_sha = params && params[:merge_request_diff_head_sha]
          quick_action_target.persisted? &&
            [MergeStrategyService::STRATEGY_MERGE_WHEN_PIPELINE_SUCCEEDS ,MergeStrategyService::STRATEGY_MERGE_IMMEDIATELY].include?(
              MergeStrategyService.new(quick_action_target.project, current_user).preferred_strategy(quick_action_target)
            )
        end
        command :merge do
          @updates[:merge] = params[:merge_request_diff_head_sha]
        end

        desc _('Merge (add to the merge train)')
        explanation _('Merges this merge request on merge train.')
        execution_message _('Scheduled to merge this merge request on merge train.')
        types MergeRequest
        condition do
          last_diff_sha = params && params[:merge_request_diff_head_sha]
          quick_action_target.persisted? &&
            MergeStrategyService.new(quick_action_target.project, current_user).preferred_strategy(quick_action_target) ==
              MergeStrategyService::STRATEGY_MERGE_TRAIN
        end
        command :merge do
          @updates[:merge] = params[:merge_request_diff_head_sha]
        end

        desc _('Merge (adds to the merge train when pipeline succeeds)')
        explanation _('Adds to the merge train when pipeline succeeds.')
        execution_message _('Scheduled to adds to the merge train when pipeline succeeds.')
        types MergeRequest
        condition do
          last_diff_sha = params && params[:merge_request_diff_head_sha]
          quick_action_target.persisted? &&
            MergeStrategyService.new(quick_action_target.project, current_user).preferred_strategy(quick_action_target) ==
              MergeStrategyService::STRATEGY_MERGE_TRAIN_WHEN_PIPELINE_SUCCEEDS
        end
        command :merge do
          @updates[:merge] = params[:merge_request_diff_head_sha]
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
          @updates[:wip_event] = quick_action_target.work_in_progress? ? 'unwip' : 'wip'
        end

        desc _('Set target branch')
        explanation do |branch_name|
          _('Sets target branch to %{branch_name}.') % { branch_name: branch_name }
        end
        execution_message do |branch_name|
          _('Set target branch to %{branch_name}.') % { branch_name: branch_name }
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
          @updates[:target_branch] = branch_name if project.repository.branch_exists?(branch_name)
        end
      end
    end
  end
end
