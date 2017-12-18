module Banzai
  module ReferenceParser
    class IssueParser < IssuableParser
      self.reference_type = :issue

      def nodes_visible_to_user(user, nodes)
        issues = records_for_nodes(nodes)

        readable_issues = Ability.issues_readable_by_user(issues.values, user).to_set

        nodes.select do |node|
          readable_issues.include?(issues[node])
        end
      end

      def records_for_nodes(nodes)
        @issues_for_nodes ||= grouped_objects_for_nodes(
          nodes,
          Issue.all.includes(
            :author,
            :assignees,
            {
              # These associations are primarily used for checking permissions.
              # Eager loading these ensures we don't end up running dozens of
              # queries in this process.
              project: [
                { namespace: :owner },
                { group: [:owners, :group_members] },
                :invited_groups,
                :project_members,
                :project_feature
              ]
            }
          ),
          self.class.data_attribute
        )
      end
    end
  end
end
