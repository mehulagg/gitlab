module Search
  class GroupService < Search::GlobalService
    attr_accessor :group

    def initialize(user, group, params)
      super(user, params)

      @default_project_filter = false
      @group = group
    end

    def projects
      return Project.none unless group
      return @projects if defined? @projects

      @projects = super.inside_path(group.full_path)
    end

    def elastic_projects
      @elastic_projects ||= projects.pluck(:id)
    end

    def elastic_global
      false
    end
  end
end
