# frozen_string_literal: true

module EE
  module Gitlab
    module DataBuilder
      module GroupMember
        extend ::Gitlab::Utils::Override

        private

        override :group_member_data
        def group_member_data(group_member)
          super.tap do |data|
            data[:group_plan] = group_member.group.gitlab_subscription&.plan_name
          end
        end
      end
    end
  end
end
