# frozen_string_literal: true

module Mutations
  module Ci
    class ConfigLint < BaseMutation
      graphql_name 'ConfigLint'

      argument :content, GraphQL::STRING_TYPE,
               required: false,
               description: 'Contents of .gitlab-ci.yml'

      argument :include_merged_yaml, GraphQL::BOOLEAN_TYPE,
                required: false,
                description: 'Whether or not to include merged CI yaml in the response'

      field :stages, Types::Ci::StageType.connection_type,
            null: true,
            description: 'Result for the YAML processor'

      field :status, GraphQL::STRING_TYPE,
            null: true,
            description: 'Status of linting, can be either valid or invalid'

      def resolve(content:, include_merged_yaml: false)
        result = Gitlab::Ci::YamlProcessor.new(content).execute

        if result.errors.empty?
          stages = stages(result.stages)
          jobs = jobs(result.jobs)
          groups = groups(jobs)
          stage_groups(stages, groups)

          response = {
                        status: 'valid',
                        errors: [],
                        stages: stages
                      }
        else
          response = { status: 'invalid', errors: [result.errors.first] }
        end

        response.tap do |response|
          response[:merged_yaml] = result.merged_yaml if include_merged_yaml
        end
      end

      private

      def stages(config_stages)
        config_stages.map { |stage| OpenStruct.new(name: stage, groups: []) }
      end

      def jobs(config_jobs)
        config_jobs.map { |job_name, job| CommitStatus.new(name: job_name, stage: job[:stage] ) }
      end

      def groups(jobs)
        group_names = jobs.map(&:group_name).uniq
        groups = group_names.map do |group|
          group_jobs = jobs.select { |job| job.group_name == group }
          ::Ci::Group.new(nil, group_jobs.first.stage, name: group, jobs: group_jobs)
        end
      end

      def stage_groups(stage_data, groups)
        stage_data.map do |stage|
          stage.groups = groups.select { |group| group.stage == stage.name }
        end
      end
    end
  end
end
