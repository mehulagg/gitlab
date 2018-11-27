# frozen_string_literal: true

module EE
  module Projects
    module MergeRequests
      module ApplicationController
        extend ActiveSupport::Concern

        private

        def merge_request_params
          clamp_approvals_before_merge(super)
        end

        def merge_request_params_attributes
          attrs = super.push(
            :approvals_before_merge,
            :approver_group_ids,
            :approver_ids
          )

          attrs
        end

        # If the number of approvals is not greater than the project default, set to
        # nil, so that we fall back to the project default. If it's not set, we can
        # let the normal update logic handle this.
        def clamp_approvals_before_merge(mr_params)
          return mr_params unless mr_params[:approvals_before_merge]

          # Target the MR target project in priority, else it depends whether the project
          # is forked.
          target_project = if @merge_request # rubocop:disable Gitlab/ModuleWithInstanceVariables
                             @merge_request.target_project # rubocop:disable Gitlab/ModuleWithInstanceVariables
                           elsif project.forked? && project.id.to_s != mr_params[:target_project_id]
                             project.forked_from_project
                           else
                             project
                           end

          if mr_params[:approvals_before_merge].to_i <= target_project.approvals_before_merge
            mr_params[:approvals_before_merge] = nil
          end

          mr_params
        end
      end
    end
  end
end
