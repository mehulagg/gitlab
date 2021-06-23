# frozen_string_literal: true

module Security
  module CiConfiguration
    class DependencyScanningBuildAction < BaseBuildAction
      def initialize(auto_devops_enabled, params, existing_gitlab_ci_content)
        super(auto_devops_enabled, existing_gitlab_ci_content)
        @variables = variables(params)
        @default_ds_values = default_ds_values(params)
        @default_values_overwritten = false
      end

      private

      def variables(params)
        collect_values(params, 'value')
      end

      def default_ds_values(params)
        collect_values(params, 'defaultValue')
      end

      def collect_values(config, key)
        global_variables = config['global']&.to_h { |k| [k['field'], k[key]] } || {}
        pipeline_variables = config['pipeline']&.to_h { |k| [k['field'], k[key]] } || {}

        analyzer_variables = collect_analyzer_values(config, key)

        global_variables.merge!(pipeline_variables).merge!(analyzer_variables)
      end

      def collect_analyzer_values(config, key)
        analyzer_variables = analyzer_variables_for(config, key)
        analyzer_variables['DS_EXCLUDED_ANALYZERS'] = if key == 'value'
                                                        config['analyzers']
                                                          &.reject {|a| a['enabled'] }
                                                          &.collect {|a| a['name'] }
                                                          &.sort
                                                          &.join(', ')
                                                      else
                                                        ''
                                                      end

        analyzer_variables
      end

      def analyzer_variables_for(config, key)
        config['analyzers']
          &.select {|a| a['enabled'] && a['variables'] }
          &.flat_map {|a| a['variables'] }
          &.collect {|v| [v['field'], v[key]] }.to_h
      end

      def update_existing_content!
        @existing_gitlab_ci_content['stages'] = set_stages
        @existing_gitlab_ci_content['variables'] = set_variables(global_variables, @existing_gitlab_ci_content)
        @existing_gitlab_ci_content['dependency_scanning'] = set_ds_block
        @existing_gitlab_ci_content['include'] = generate_includes

        @existing_gitlab_ci_content.select! { |k, v| v.present? }
        @existing_gitlab_ci_content['dependency_scanning'].select! { |k, v| v.present? }
      end

      def set_stages
        existing_stages = @existing_gitlab_ci_content['stages'] || []
        base_stages = @auto_devops_enabled ? auto_devops_stages : ['test']
        (existing_stages + base_stages + [ds_stage]).uniq
      end

      def auto_devops_stages
        auto_devops_template = YAML.safe_load( Gitlab::Template::GitlabCiYmlTemplate.find('Auto-DevOps').content )
        auto_devops_template['stages']
      end

      def ds_stage
        @variables['stage'].presence ? @variables['stage'] : 'test'
      end

      def set_variables(variables, hash_to_update = {})
        hash_to_update['variables'] ||= {}

        variables.each do |key|
          if @variables[key].present? && @variables[key].to_s != @default_ds_values[key].to_s
            hash_to_update['variables'][key] = @variables[key]
            @default_values_overwritten = true
          else
            hash_to_update['variables'].delete(key)
          end
        end

        hash_to_update['variables']
      end

      def set_ds_block
        ds_content = @existing_gitlab_ci_content['dependency_scanning'] || {}
        ds_content['variables'] = set_variables(ds_variables)
        ds_content['stage'] = ds_stage
        ds_content.select { |k, v| v.present? }
      end

      def template
        return 'Auto-DevOps.gitlab-ci.yml' if @auto_devops_enabled

        'Security/Dependency-Scanning.gitlab-ci.yml'
      end

      def global_variables
        %w(
          SECURE_ANALYZERS_PREFIX
          SECURE_LOG_LEVEL
       )
      end

      def ds_variables
        %w(
          DS_EXCLUDED_PATHS
          DS_EXCLUDED_ANALYZERS
        )
      end
    end
  end
end
