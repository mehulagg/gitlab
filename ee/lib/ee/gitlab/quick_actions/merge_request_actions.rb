# frozen_string_literal: true

module EE
  module Gitlab
    module QuickActions
      module MergeRequestActions
        include ::Gitlab::QuickActions::Dsl

        desc _('Approve a merge request')
        explanation _('Approve the current merge request.')
        types MergeRequest
        condition do
          quick_action_target.persisted? && quick_action_target.can_approve?(current_user) && !quick_action_target.project.require_password_to_approve?
        end
        command :approve do
          if quick_action_target.can_approve?(current_user)
            ::MergeRequests::ApprovalService.new(quick_action_target.project, current_user).execute(quick_action_target)
            info _('Approved the current merge request.')
          else
            warn _('You cannot approve this merge request')
          end
        end
      end
    end
  end
end
