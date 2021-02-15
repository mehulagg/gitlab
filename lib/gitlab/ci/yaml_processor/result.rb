# frozen_string_literal: true

# A data object that wraps `Ci::Config` and any messages
# (errors, warnings) generated by the YamlProcessor.
module Gitlab
  module Ci
    class YamlProcessor
      class Result
        attr_reader :errors, :warnings

        def initialize(ci_config: nil, errors: [], warnings: [])
          @ci_config = ci_config
          @errors = errors || []
          @warnings = warnings || []
        end

        def valid?
          errors.empty?
        end

        def stages_attributes
          stages.uniq.map do |stage|
            seeds = stage_builds_attributes(stage)

            { name: stage, index: stages.index(stage), builds: seeds }
          end
        end

        def builds
          jobs.map do |name, _|
            build_attributes(name)
          end
        end

        def stage_builds_attributes(stage)
          jobs.values
            .select { |job| job[:stage] == stage }
            .map { |job| build_attributes(job[:name]) }
        end

        def workflow_attributes
          {
            rules: hash_config.dig(:workflow, :rules),
            yaml_variables: transform_to_yaml_variables(variables)
          }
        end

        def jobs
          @jobs ||= @ci_config.normalized_jobs
        end

        def stages
          @stages ||= @ci_config.stages
        end

        def included_templates
          @included_templates ||= @ci_config.included_templates
        end

        def build_attributes(name)
          job = jobs.fetch(name.to_sym, {})

          { stage_idx: stages.index(job[:stage]),
            stage: job[:stage],
            tag_list: job[:tags],
            name: job[:name].to_s,
            allow_failure: job[:ignore],
            when: job[:when] || 'on_success',
            environment: job[:environment_name],
            coverage_regex: job[:coverage],
            yaml_variables: transform_to_yaml_variables(job[:variables]),
            needs_attributes: job.dig(:needs, :job),
            interruptible: job[:interruptible],
            only: job[:only],
            except: job[:except],
            rules: job[:rules],
            cache: job[:cache],
            resource_group_key: job[:resource_group],
            scheduling_type: job[:scheduling_type],
            secrets: job[:secrets],
            options: {
              image: job[:image],
              services: job[:services],
              allow_failure_criteria: job[:allow_failure_criteria],
              artifacts: job[:artifacts],
              dependencies: job[:dependencies],
              cross_dependencies: job.dig(:needs, :cross_dependency),
              job_timeout: job[:timeout],
              before_script: job[:before_script],
              script: job[:script],
              after_script: job[:after_script],
              environment: job[:environment],
              retry: job[:retry],
              parallel: job[:parallel],
              instance: job[:instance],
              start_in: job[:start_in],
              trigger: job[:trigger],
              bridge_needs: job.dig(:needs, :bridge)&.first,
              release: release(job)
            }.compact }.compact
        end

        def merged_yaml
          @ci_config&.to_hash&.deep_stringify_keys.to_yaml
        end

        def variables_with_data
          @ci_config.variables_with_data
        end

        private

        def variables
          @variables ||= @ci_config.variables
        end

        def hash_config
          @hash_config ||= @ci_config.to_hash
        end

        def release(job)
          job[:release]
        end

        def transform_to_yaml_variables(variables)
          ::Gitlab::Ci::Variables::Helpers.transform_to_yaml_variables(variables)
        end
      end
    end
  end
end
