# frozen_string_literal: true

# This returns an app descriptor for use with Jira in development mode
# For the Atlassian Marketplace, a static copy of this JSON is uploaded to the marketplace
# https://developer.atlassian.com/cloud/jira/platform/app-descriptor/

class JiraConnect::AppDescriptorController < JiraConnect::ApplicationController
  skip_before_action :verify_atlassian_jwt!

  def show
    render json: {
      name: Atlassian::JiraConnect.app_name,
      description: 'Integrate commits, branches and merge requests from GitLab into Jira',
      key: Atlassian::JiraConnect.app_key,
      baseUrl: jira_connect_base_url(protocol: 'https'),
      lifecycle: {
        installed: relative_to_base_path(jira_connect_events_installed_path),
        uninstalled: relative_to_base_path(jira_connect_events_uninstalled_path)
      },
      vendor: {
        name: 'GitLab',
        url: 'https://gitlab.com'
      },
      links: {
        documentation: help_page_url('integration/jira_development_panel', anchor: 'gitlabcom-1')
      },
      authentication: {
        type: 'jwt'
      },
      modules: modules,
      scopes: %w(READ WRITE DELETE),
      apiVersion: 1,
      apiMigrations: {
        gdpr: true
      }
    }
  end

  private

  def modules
    modules = {
      jiraDevelopmentTool: {
        key: 'gitlab-development-tool',
        application: {
          value: 'GitLab'
        },
        name: {
          value: 'GitLab'
        },
        url: home_url,
        logoUrl: view_context.image_url('gitlab_logo.png'),
        capabilities: %w(branch commit pull_request)
      },
      postInstallPage: {
        key: 'gitlab-configuration',
        name: {
          value: 'GitLab Configuration'
        },
        url: relative_to_base_path(jira_connect_subscriptions_path)
      }
    }

    modules.merge!(build_information_module)

    modules
  end

  def home_url
    'https://gitlab.com'
  end

  def doc_url
    'https://docs.gitlab.com/ee/user/project/integrations/jira.html#gitlab-jira-integration'
  end

  # See: https://developer.atlassian.com/cloud/jira/software/modules/build/
  def build_information_module
    {
      "jiraBuildInfoProvider": {
        "homeUrl": home_url,
        "logoUrl": view_context.image_url('gitlab_logo.png'),
        "documentationUrl": doc_url,
        "actions": {},
        "name": {
          "value": "GitLab CI"
        },
        "key": "gitlab-ci"
      }
    }
  end

  def relative_to_base_path(full_path)
    full_path.sub(/^#{jira_connect_base_path}/, '')
  end
end
