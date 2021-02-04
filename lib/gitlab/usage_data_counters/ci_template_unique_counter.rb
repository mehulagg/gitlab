# frozen_string_literal: true

module Gitlab::UsageDataCounters
  class CiTemplateUniqueCounter
    REDIS_SLOT = 'ci_templates'.freeze

    # NOTE! Events with config_source :auto_devops_source get suffixed with _implicit
    TEMPLATE_TO_EVENT = {
      'Auto-DevOps.gitlab-ci.yml' => 'auto_devops',
      'AWS/CF-Provision-and-Deploy-EC2.gitlab-ci.yml' => 'aws_cf_deploy_ec2',
      'AWS/Deploy-ECS.gitlab-ci.yml' => 'aws_deploy_ecs',
      'Jobs/Build.gitlab-ci.yml' => 'auto_devops_build',
      'Jobs/Deploy.gitlab-ci.yml' => 'auto_devops_deploy',
      'Jobs/Deploy.latest.gitlab-ci.yml' => 'auto_devops_deploy_latest',
      'Security/SAST.gitlab-ci.yml' => 'security_sast',
      'Security/Secret-Detection.gitlab-ci.yml' => 'security_secret_detection',
      'Terraform/Base.latest.gitlab-ci.yml' => 'terraform_base_latest'
    }.freeze

    class << self
      def track_unique_project_event(project_id:, template:, config_source:)
        return if Feature.disabled?(:usage_data_track_ci_templates_unique_projects, default_enabled: :yaml)

        if event = unique_project_event(template, config_source)
          Gitlab::UsageDataCounters::HLLRedisCounter.track_event(event, values: project_id)
        end
      end

      private

      def unique_project_event(template, config_source)
        if name = TEMPLATE_TO_EVENT[template]
          suffix = '_implicit' if config_source == :auto_devops_source

          "p_#{REDIS_SLOT}_#{name}#{suffix}"
        end
      end
    end
  end
end
