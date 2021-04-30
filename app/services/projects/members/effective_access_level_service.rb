# frozen_string_literal: true

module Projects
  module Members
    class EffectiveAccessLevelService
      def initialize(project)
        @project = project
      end

      def execute
        Member.from_union(all_possible_avenues_of_membership)
          .select([:user_id, 'MAX(access_level) AS access_level'])
          .group(:user_id) # rubocop: disable CodeReuse/ActiveRecord
      end

      private

      attr_reader :project

      def all_possible_avenues_of_membership
        avenues = [project_members_without_invites_and_requests]

        avenues << if project.group
                     members_from_group
                   else
                     project_owner_acting_as_maintainer
                   end

        if include_membership_from_project_group_shares?
          avenues << members_from_project_group_shares
        end

        avenues
      end

      def project_members_without_invites_and_requests
        project.members.without_invites_and_requests.select(*user_id_and_access_level)
      end

      def members_from_group
        project.group.members_with_parents.select(*user_id_and_access_level)
      end

      def project_owner_acting_as_maintainer
        # rubocop: disable CodeReuse/ActiveRecord
        Project.where(id: project.id)
          .select(*user_id_and_access_level_with_owner_as_maintainer)
          .reorder(nil)
        # rubocop: enable CodeReuse/ActiveRecord
      end

      def members_from_project_group_shares
        members = []

        project.project_group_links.find_each do |link|
          members << link.group.members_with_parents.select(*user_id_and_access_level_for_project_group_shares(link))
        end

        Member.from_union(members)
      end

      def include_membership_from_project_group_shares?
        project.allowed_to_share_with_group? && project.project_group_links.any?
      end

      # methods for `select` options

      def user_id_and_access_level
        [:user_id, :access_level]
      end

      def user_id_and_access_level_with_owner_as_maintainer
        [
          "#{project.namespace.owner.id} as user_id",
          "#{Gitlab::Access::MAINTAINER} as access_level"
        ]
      end

      def user_id_and_access_level_for_project_group_shares(link)
        least_access_level_among_group_membership_and_project_share =
          smallest_value_arel([link.group_access, GroupMember.arel_table[:access_level]], 'access_level')

        [
          :user_id,
          least_access_level_among_group_membership_and_project_share
        ]
      end

      def smallest_value_arel(args, column_alias)
        Arel::Nodes::As.new(
          Arel::Nodes::NamedFunction.new('LEAST', args),
          Arel::Nodes::SqlLiteral.new(column_alias)
        )
      end
    end
  end
end
