# frozen_string_literal: true

module Resolvers
  module Ci
    class ConfigResolver < BaseResolver

      argument :content, GraphQL::STRING_TYPE,
               required: true,
               description: 'Contents of .gitlab-ci.yml'

      argument :include_merged_yaml, GraphQL::BOOLEAN_TYPE,
                required: false,
                description: 'Whether or not to include merged CI yaml in the response'

      def resolve(content:, include_merged_yaml: false)
        result = Gitlab::Ci::YamlProcessor.new(content).execute

        if result.errors.empty?
          stages = stages(result.stages)
          jobs = jobs(result.jobs)
          groups = groups(jobs)
          stages = stage_groups(stages, groups)

          response = {
                        status: 'valid',
                        errors: [],
                        stages: stages.select { |stage| !stage[:groups].empty? }
                     }
        else
          response = {
                        status: 'invalid',
                        errors: [result.errors.first]
                     }
        end

        response.tap do |response|
          response[:merged_yaml] = result.merged_yaml if include_merged_yaml
        end
      end

      private

      def stages(config_stages)
        config_stages.map { |stage|  { name: stage, groups: [] } }
      end

      def jobs(config_jobs)
        config_jobs.map do |job_name, job|
          {
            name: job_name,
            stage: job[:stage],
            group_name: CommitStatus.new(name: job_name).group_name,
            needs: needs(job) || []
          }
        end
      end

      def needs(job)
        job[:needs][:job]&.map do |job_need|
          { name: job_need[:name], artifacts: job_need[:artifacts] }
        end
      end

      def groups(jobs)
        group_names = jobs.map { |job| job[:group_name] }.uniq
        group_names.map do |group|
          group_jobs = jobs.select { |job| job[:group_name] == group }
          { jobs: group_jobs, name: group, stage: group_jobs.first[:stage], size: group_jobs.count }
        end
      end

      def stage_groups(stage_data, groups)
        stage_data.each do |stage|
          stage[:groups] = groups.select { |group| group[:stage] == stage[:name] }
        end
      end
    end
  end
end
