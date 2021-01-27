# frozen_string_literal: true

module Gitlab
  module Ci
    module Variables
      class Builder
        class Project
          def initialize(scope)
            @project = scope
          end

          def fabricate
            Gitlab::Ci::Variables::Collection.new
              .concat(predefined_ci_server_variables)
              .concat(predefined_project_variables)
              .concat(pages_variables)
              .concat(container_registry_variables)
              .concat(dependency_proxy_variables)
              .concat(auto_devops_variables)
              .concat(api_variables)
          end

          private

          def predefined_ci_server_variables
            Gitlab::Ci::Variables::Collection.new
              .append(key: 'CI', value: 'true')
              .append(key: 'GITLAB_CI', value: 'true')
              .append(key: 'CI_SERVER_URL', value: Gitlab.config.gitlab.url)
              .append(key: 'CI_SERVER_HOST', value: Gitlab.config.gitlab.host)
              .append(key: 'CI_SERVER_PORT', value: Gitlab.config.gitlab.port.to_s)
              .append(key: 'CI_SERVER_PROTOCOL', value: Gitlab.config.gitlab.protocol)
              .append(key: 'CI_SERVER_NAME', value: 'GitLab')
              .append(key: 'CI_SERVER_VERSION', value: Gitlab::VERSION)
              .append(key: 'CI_SERVER_VERSION_MAJOR', value: Gitlab.version_info.major.to_s)
              .append(key: 'CI_SERVER_VERSION_MINOR', value: Gitlab.version_info.minor.to_s)
              .append(key: 'CI_SERVER_VERSION_PATCH', value: Gitlab.version_info.patch.to_s)
              .append(key: 'CI_SERVER_REVISION', value: Gitlab.revision)
          end

          def predefined_project_variables
            Gitlab::Ci::Variables::Collection.new
              .append(key: 'GITLAB_FEATURES', value: @project.licensed_features.join(','))
              .append(key: 'CI_PROJECT_ID', value: @project.id.to_s)
              .append(key: 'CI_PROJECT_NAME', value: @project.path)
              .append(key: 'CI_PROJECT_TITLE', value: @project.title)
              .append(key: 'CI_PROJECT_PATH', value: @project.full_path)
              .append(key: 'CI_PROJECT_PATH_SLUG', value: @project.full_path_slug)
              .append(key: 'CI_PROJECT_NAMESPACE', value: @project.namespace.full_path)
              .append(key: 'CI_PROJECT_ROOT_NAMESPACE', value: @project.namespace.root_ancestor.path)
              .append(key: 'CI_PROJECT_URL', value: @project.web_url)
              .append(key: 'CI_PROJECT_VISIBILITY', value: Gitlab::VisibilityLevel.string_level(@project.visibility_level))
              .append(key: 'CI_PROJECT_REPOSITORY_LANGUAGES', value: @project.repository_languages.map(&:name).join(',').downcase)
              .append(key: 'CI_DEFAULT_BRANCH', value: @project.default_branch)
              .append(key: 'CI_PROJECT_CONFIG_PATH', value: @project.ci_config_path_or_default)
          end

          def pages_variables
            Gitlab::Ci::Variables::Collection.new.tap do |variables|
              break unless @project.pages_enabled?

              variables.append(key: 'CI_PAGES_DOMAIN', value: Gitlab.config.pages.host)
              variables.append(key: 'CI_PAGES_URL', value: @project.pages_url)
            end
          end

          def container_registry_variables
            Gitlab::Ci::Variables::Collection.new.tap do |variables|
              break variables unless Gitlab.config.registry.enabled

              variables.append(key: 'CI_REGISTRY', value: Gitlab.config.registry.host_port)

              if @project.container_registry_enabled?
                variables.append(key: 'CI_REGISTRY_IMAGE', value: @project.container_registry_url)
              end
            end
          end

          def dependency_proxy_variables
            Gitlab::Ci::Variables::Collection.new.tap do |variables|
              break variables unless Gitlab.config.dependency_proxy.enabled

              variables.append(key: 'CI_DEPENDENCY_PROXY_SERVER', value: "#{Gitlab.config.gitlab.host}:#{Gitlab.config.gitlab.port}")
              variables.append(
                key: 'CI_DEPENDENCY_PROXY_GROUP_IMAGE_PREFIX',
                value: "#{Gitlab.config.gitlab.host}:#{Gitlab.config.gitlab.port}/#{@project.namespace.root_ancestor.path}#{DependencyProxy::URL_SUFFIX}"
              )
            end
          end

          def auto_devops_variables
            return [] unless @project.auto_devops_enabled?

            (@project.auto_devops || @project.build_auto_devops)&.predefined_variables
          end

          def api_variables
            Gitlab::Ci::Variables::Collection.new.tap do |variables|
              variables.append(key: 'CI_API_V4_URL', value: API::Helpers::Version.new('v4').root_url)
            end
          end
        end
      end
    end
  end
end
