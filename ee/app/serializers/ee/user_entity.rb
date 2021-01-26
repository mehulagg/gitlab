# frozen_string_literal: true

module EE
  module UserEntity
    extend ActiveSupport::Concern

    prepended do
      expose :applicable_approval_rules, if: proc { |_, options| options[:project]&.feature_available?(:merge_request_approvers) && options[:approval_rules] }, using: ::EE::API::Entities::ApprovalRuleShort do |user, options|
        options[:project]&.applicable_approval_rules_for_user(user.id, options[:target_branch])
      end
    end
  end
end
