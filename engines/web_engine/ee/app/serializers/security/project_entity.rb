# frozen_string_literal: true

module Security
  class ProjectEntity < API::Entities::BasicProjectDetails
    include RequestAwareEntity

    expose :remove_path do |project|
      security_project_path(id: project.id)
    end
  end
end
