# frozen_string_literal: true

module API
  class ProjectAliases < Grape::API::Instance
    include PaginationParams

    before { check_feature_availability }
    before { authenticated_as_admin! }

    helpers do
      def project_alias
        ProjectAlias.find_by_name!(params[:name])
      end

      def project
        find_project!(params[:project_id])
      end

      def check_feature_availability
        forbidden! unless ::License.feature_available?(:project_aliases)
      end
    end

    resource :project_aliases do
      desc 'Get a list of all project aliases' do
        success EE::API::Entities::ProjectAlias
      end
      params do
        use :pagination
      end
      get do
        present paginate(ProjectAlias.all), with: EE::API::Entities::ProjectAlias
      end

      desc 'Get info of specific project alias by name' do
        success EE::API::Entities::ProjectAlias
      end
      get ':name' do
        present project_alias, with: EE::API::Entities::ProjectAlias
      end

      desc 'Create a project alias'
      params do
        requires :project_id, type: String, desc: 'The ID or URL-encoded path of the project'
        requires :name, type: String, desc: 'The alias of the project'
      end
      post do
        project_alias = project.project_aliases.create(name: params[:name])

        if project_alias.valid?
          present project_alias, with: EE::API::Entities::ProjectAlias
        else
          render_validation_error!(project_alias)
        end
      end

      desc 'Delete a project alias by name'
      delete ':name' do
        project_alias.destroy

        no_content!
      end
    end
  end
end
