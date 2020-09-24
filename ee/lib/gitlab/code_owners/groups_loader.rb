# frozen_string_literal: true

module Gitlab
  module CodeOwners
    class GroupsLoader
      def initialize(project, extractor)
        @project = project
        @extractor = extractor
      end

      def load_to(entries)
        groups = load_groups
        entries.each do |entry|
          entry.add_matching_groups_from(groups)
        end
      end

      private

      attr_reader :extractor, :project

      def load_groups
        return Group.none if extractor.names.empty?

        groups = project.invited_groups.where_full_path_in(extractor.names)

        if Feature.enabled?(:codeowners_match_ancestor_groups, default_enabled: true)
          group_list = groups.with_route.with_users.to_a

          if project.group
            # If the project.group's ancestor group(s) are listed as owners, add
            #   them to group_list
            #
            if applicable_ancestors(extractor.names).any?
              group_list.concat(applicable_ancestors(extractor.names))
            end
          end

          group_list.uniq
        else
          groups.with_route.with_users
        end
      end

      def applicable_ancestors(extractor_names)
        ancestor_groups = project.group.self_and_ancestors.with_route.with_users

        ancestor_groups.select { |group| extractor_names.include?(group.full_path) }
      end
    end
  end
end
