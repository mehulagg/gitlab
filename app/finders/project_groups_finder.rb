# frozen_string_literal: true

# ProjectGroupsFinder
#
# Used to filter Groups by a set of params
#
# Arguments:
#   project
#   current_user - which user is requesting groups
#   params:
#     with_shared: boolean
#     shared_min_access_level: integer
#
class ProjectGroupsFinder < UnionFinder
  include CustomAttributesFilter

  def initialize(project:, current_user: nil, params: {})
    @project = project
    @current_user = current_user
    @params = params
  end

  def execute
    return [] unless authorized?

    items = all_groups.map do |item|
      item = by_custom_attributes(item)
      item
    end

    find_union(items, Group).with_route.order_id_desc
  end

  private

  attr_reader :project, :current_user, :params

  def authorized?
    Ability.allowed?(current_user, :read_project, project)
  end

  # rubocop: disable CodeReuse/ActiveRecord
  def all_groups
    groups = []
    groups << project.group&.self_and_ancestors if project.group

    if params[:with_shared]
      shared_groups = project.invited_groups

      if params[:shared_min_access_level]
        shared_groups = shared_groups.where(
          'project_group_links.group_access >= ?', params[:shared_min_access_level]
        )
      end

      groups << shared_groups
    end

    groups << Group.none if groups.empty?
    groups
  end
  # rubocop: enable CodeReuse/ActiveRecord
end
