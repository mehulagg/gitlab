# frozen_string_literal: true
# rubocop:disable Graphql/ResolverType (inherited from MembersResolver)

module Resolvers
  class ProjectMembersResolver < MembersResolver
    authorize :read_project_member

    argument :relations, [ProjectMemberRelationEnum],
              description: 'Filter members by the given member relations',
              required: false

    private

    def finder_class
      MembersFinder
    end
  end
end
