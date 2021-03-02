# frozen_string_literal: true

module EE
  module API
    module Entities
      class ApprovalSettings < Grape::Entity
        expose :approvers, using: EE::API::Entities::Approver
        expose :approver_groups, using: EE::API::Entities::ApproverGroup
        expose :approvals_before_merge

        expose :reset_approvals_on_push do |object|
          !!object.reset_approvals_on_push
        end

        expose :disable_overriding_approvers_per_merge_request do |object|
          !!object.disable_overriding_approvers_per_merge_request
        end

        expose :merge_requests_author_approval do |object|
          !!object.merge_requests_author_approval
        end

        expose :merge_requests_disable_committers_approval do |object|
          !!object.merge_requests_disable_committers_approval
        end

        expose :require_password_to_approve do |object|
          !!object.require_password_to_approve
        end
      end
    end
  end
end
