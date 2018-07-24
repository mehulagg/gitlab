class PersonalProjectsFinder < UnionFinder
  def initialize(user, params = {})
    @user = user
    @params = params
  end

  # Finds the projects belonging to the user in "@user", limited to either
  # public projects or projects visible to the given user.
  #
  # current_user - When given the list of projects is limited to those only
  #                visible by this user.
  # params       - Optional query parameters
  #                  min_access_level: integer
  #
  # Returns an ActiveRecord::Relation.
  def execute(current_user = nil)
    segments = all_projects(current_user)

    find_union(segments, Project).includes(:namespace).order_updated_desc
  end

  private

  def all_projects(current_user)
    return [projects_with_min_access_level(current_user)] if current_user && min_access_level?

    projects = []
    projects << @user.personal_projects.visible_to_user(current_user) if current_user
    projects << @user.personal_projects.public_to_user(current_user)
    projects
  end

  def projects_with_min_access_level(current_user)
    @user
      .personal_projects
      .visible_to_user_and_access_level(current_user, @params[:min_access_level])
  end

  def min_access_level?
    @params[:min_access_level].present?
  end
end
