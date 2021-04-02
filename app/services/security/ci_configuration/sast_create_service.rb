# frozen_string_literal: true

module Security
  module CiConfiguration
    class SastCreateService < ::Security::CiConfiguration::BaseCreateService
      private

      def actions
        Security::CiConfiguration::SastBuildActions.new(@project.auto_devops_enabled?, @params, existing_gitlab_ci_content).generate
      end

      def next_branch
        'set-sast-config'
      end

      def message
        _('Set .gitlab-ci.yml to enable or configure SAST')
      end

      def description
        _('Set .gitlab-ci.yml to enable or configure SAST security scanning using the GitLab managed template. You can [add variable overrides](https://docs.gitlab.com/ee/user/application_security/sast/#customizing-the-sast-settings) to customize SAST settings.')
      end
    end
  end
end
