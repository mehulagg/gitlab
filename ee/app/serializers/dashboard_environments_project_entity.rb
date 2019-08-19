# frozen_string_literal: true

class DashboardEnvironmentsProjectEntity < Grape::Entity
  include RequestAwareEntity

  expose :id
  expose :name
  expose :avatar_url
  expose :web_url

  expose :remove_path do |project|
    remove_operations_project_path(project_id: project.id)
  end

  expose :namespace, using: API::Entities::NamespaceBasic
  expose :environments, using: DashboardEnvironmentsEnvironmentEntity do |project|
    Environment.within_folders(project.environments.available)
  end
end
