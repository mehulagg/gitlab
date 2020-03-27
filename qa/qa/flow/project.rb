# frozen_string_literal: true

module QA
  module Flow
    module Project
      extend Support::Api

      module_function

      def add_member(project:, username:)
        project.visit!

        Page::Project::Menu.perform(&:go_to_members_settings)

        Page::Project::Settings::Members.perform do |member_settings|
          member_settings.add_member(username)
        end
      end

      def create_project(project_name, api_client, project_description = 'default')
        project = Resource::Project.fabricate_via_api! do |project|
          project.add_name_uuid = false
          project.name = project_name
          project.description = project_description
          project.api_client = api_client
          project.visibility = 'public'
        end
        project
      end

      def push_file_to_project(target_project, file_name, file_content)
        Resource::Repository::ProjectPush.fabricate! do |push|
          push.project = target_project
          push.file_name = file_name
          push.file_content = file_content
        end
      end

      def set_project_visibility(api_client, project_id, visibility)
        request = Runtime::API::Request.new(api_client, "/projects/#{project_id}")
        response = put request.url, visibility: visibility
        response.code.equal?(QA::Support::Api::HTTP_STATUS_OK)
      end
    end
  end
end
