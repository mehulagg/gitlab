# frozen_string_literal: true

module Ci
  class RunDastScanService < BaseService
    ENV_MAPPING = {
      spider_timeout: 'DAST_SPIDER_MINS',
      target_timeout: 'DAST_TARGET_AVAILABILITY_TIMEOUT',
      target_url: 'DAST_WEBSITE',
      use_ajax_spider: 'DAST_USE_AJAX_SPIDER',
      show_debug_messages: 'DAST_DEBUG',
      scan_type: 'DAST_FULL_SCAN_ENABLED'
    }.freeze

    def self.ci_template_raw
      @ci_template_raw ||= Gitlab::Template::GitlabCiYmlTemplate.find('DAST').content
    end

    def self.ci_template
      @ci_template ||= YAML.safe_load(ci_template_raw).tap do |template|
        template['stages'] = ['dast']
        template['dast'].delete('rules')
      end
    end

    def execute(branch:, **args)
      return ServiceResponse.error(message: 'Insufficient permissions') unless allowed?

      service = Ci::CreatePipelineService.new(project, current_user, ref: branch)
      pipeline = service.execute(:ondemand_dast_scan, content: ci_yaml(args))

      if pipeline.created_successfully?
        ServiceResponse.success(payload: pipeline)
      else
        ServiceResponse.error(message: pipeline.full_error_messages)
      end
    end

    private

    def allowed?
      Ability.allowed?(current_user, :create_on_demand_dast_scan, project)
    end

    def ci_yaml(args)
      variables = args.each_with_object({}) do |(key, val), hash|
        next unless val && ENV_MAPPING[key]

        next if !!val == val && !val

        if ENV_MAPPING[key] == 'DAST_FULL_SCAN_ENABLED'
          next if val != 'active'

          val = true
        end

        hash[ENV_MAPPING[key]] = !!val == val ? val.to_s : val
        hash
      end

      self.class.ci_template.deep_merge(
        'variables' => variables
      ).to_yaml
    end
  end
end
