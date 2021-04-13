# frozen_string_literal: true

module Security
  module CiConfiguration
    class SecretDetectionCreateService < ::Security::CiConfiguration::BaseCreateService
      private

      def actions
        Security::CiConfiguration::SecretDetectionBuildActions.new(project.auto_devops_enabled?, params, existing_gitlab_ci_content).generate
      end

      def next_branch
        'set-secret-detection-config'
      end

      def message
        _('Set .gitlab-ci.yml to configure Secret Detection')
      end

      def description
        _('Set .gitlab-ci.yml to enable or configure Secret Detection security scanning using the GitLab managed template. You can [add variable overrides](https://docs.gitlab.com/ee/user/application_security/secret_detection/#customizing-settings) to customize Secret Detection settings.')
      end
    end
  end
end
