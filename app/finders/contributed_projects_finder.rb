# frozen_string_literal: true

class ContributedProjectsFinder < UnionFinder
  def initialize(user, params = {})
    @user = user
    @params = params
  end

  # Finds the projects "@user" contributed to, limited to either public projects
  # or projects visible to the given user.
  #
  # current_user - When given the list of the projects is limited to those only
  #                visible by this user.
  # params       - Optional query parameters
  #                  pinned: boolean
  #
  # Returns an ActiveRecord::Relation.
  # rubocop: disable CodeReuse/ActiveRecord
  def execute(current_user = nil)
    # Do not show contributed projects if the user profile is private.
    return Project.none unless can_read_profile?(current_user)

    segments = all_projects(current_user)

    query = find_union(segments, Project).includes(:namespace)

    if @params[:pinned]
      query = query.with_pinned
    else
      query = query.order_updated_desc
    end

    query
  end
  # rubocop: enable CodeReuse/ActiveRecord

  private

  def can_read_profile?(current_user)
    Ability.allowed?(current_user, :read_user_profile, @user)
  end

  def all_projects(current_user)
    projects = []

    projects << @user.contributed_projects.visible_to_user(current_user) if current_user
    projects << @user.contributed_projects.public_to_user(current_user)

    projects
  end
end
