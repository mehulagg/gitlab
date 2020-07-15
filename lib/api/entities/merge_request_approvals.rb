# frozen_string_literal: true

module API
  module Entities
    class MergeRequestApprovals < Grape::Entity
      expose :user_has_approved do |merge_request, options|
        merge_request.has_approved?(options[:current_user])
      end

      expose :user_can_approve do |merge_request, options|
        !merge_request.has_approved?(options[:current_user]) &&
          options[:current_user].can?(:approve_merge_request, merge_request)
      end

      expose :approved do |merge_request|
        merge_request.approvals.present?
      end

      expose :approved_by, using: ::API::Entities::Approvals do |merge_request|
        merge_request.approvals
      end
    end
  end
end
