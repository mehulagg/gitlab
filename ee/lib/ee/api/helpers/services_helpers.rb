# frozen_string_literal: true

module EE
  module API
    module Helpers
      module ServicesHelpers
        extend ActiveSupport::Concern

        class_methods do
          extend ::Gitlab::Utils::Override

          override :services
          def services
            super.merge(
              'github' => [
                {
                  required: true,
                  name: :token,
                  type: String,
                  desc: 'GitHub API token with repo:status OAuth scope'
                },
                {
                  required: true,
                  name: :repository_url,
                  type: String,
                  desc: "GitHub repository URL"
                },
                {
                  required: false,
                  name: :static_context,
                  type: ::API::Services::Boolean,
                  desc: 'Append instance name instead of branch to status check name'
                }
              ],
              'jenkins' => [
                {
                  required: true,
                  name: :jenkins_url,
                  type: String,
                  desc: 'Jenkins root URL like https://jenkins.example.com'
                },
                {
                  required: true,
                  name: :project_name,
                  type: String,
                  desc: 'The URL-friendly project name. Example: my_project_name'
                },
                {
                  required: false,
                  name: :username,
                  type: String,
                  desc: 'A user with access to the Jenkins server, if applicable'
                },
                {
                  required: false,
                  name: :password,
                  type: String,
                  desc: 'The password of the user'
                }
              ]
            )
          end

          override :service_classes
          def service_classes
            [
              ::GithubService,
              ::JenkinsService,
              *super
            ]
          end
        end
      end
    end
  end
end
