# frozen_string_literal: true

###
# API endpoints for the RubyGem package registry
module API
  class RubygemPackages < ::API::Base
    helpers ::API::Helpers::PackagesHelpers

    # The Marshal version can be found by "#{Marshal::MAJOR_VERSION}.#{Marshal::MINOR_VERSION}"
    # Updating the version should require a GitLab API version change.
    MARSHAL_VERSION = '4.8'

    FILE_NAME_REQUIREMENTS = {
      file_name: API::NO_SLASH_URL_PART_REGEX
    }.freeze

    content_type :binary, 'application/octet-stream'

    before do
      require_packages_enabled!
      authenticate!
      not_found! unless Feature.enabled?(:rubygem_packages, user_project)
    end

    helpers do
      # we override this auth_finders.rb method because RubyGems does not
      # include a "Token" or "Bearer" prefix.
      def parsed_oauth_token
        request.headers['Authorization']
      end
    end

    params do
      requires :id, type: String, desc: 'The ID or full path of a project'
    end
    resource :projects, requirements: API::NAMESPACE_OR_PROJECT_REQUIREMENTS do
      namespace ':id/packages/rubygems' do
        desc 'Download the spec index file' do
          detail 'This feature was introduced in GitLab 13.9'
        end
        params do
          requires :file_name, type: String, desc: 'Spec file name'
        end
        route_setting :authentication, deploy_token_allowed: true, job_token_allowed: true
        get ":file_name", requirements: FILE_NAME_REQUIREMENTS do
          not_found!
        end

        desc 'Download the gemspec file' do
          detail 'This feature was introduced in GitLab 13.9'
        end
        params do
          requires :file_name, type: String, desc: 'Gemspec file name'
        end
        route_setting :authentication, deploy_token_allowed: true, job_token_allowed: true
        get "quick/Marshal.#{MARSHAL_VERSION}/:file_name", requirements: FILE_NAME_REQUIREMENTS do
          not_found!
        end

        desc 'Download the .gem package' do
          detail 'This feature was introduced in GitLab 13.9'
        end
        params do
          requires :file_name, type: String, desc: 'Package file name'
        end
        route_setting :authentication, deploy_token_allowed: true, job_token_allowed: true
        get "gems/:file_name", requirements: FILE_NAME_REQUIREMENTS do
          not_found!
        end

        namespace 'api/v1' do
          desc 'Authorize a gem upload' do
            detail 'This feature was introduced in GitLab 13.9'
          end
          route_setting :authentication, deploy_token_allowed: true, job_token_allowed: true
          post 'gems/authorize' do
            not_found!
          end

          desc 'Upload a gem' do
            detail 'This feature was introduced in GitLab 13.9'
          end
          route_setting :authentication, deploy_token_allowed: true, job_token_allowed: true
          post 'gems' do
            not_found!
          end

          desc 'Fetch a list of dependencies' do
            detail 'This feature was introduced in GitLab 13.9'
          end
          params do
            optional :gems, type: String, desc: 'Comma delimited gem names'
          end
          route_setting :authentication, deploy_token_allowed: true, job_token_allowed: true
          get 'dependencies' do
            not_found!
          end
        end
      end
    end
  end
end
