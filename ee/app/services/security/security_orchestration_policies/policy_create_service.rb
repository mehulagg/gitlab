# frozen_string_literal: true

module Security
  module SecurityOrchestrationPolicies
    class PolicyCreateService < ::BaseProjectService
      include Stepable

      steps :check_policy_project,
            :create_or_update_policy,
            :create_merge_request

      def execute
        execute_steps
      end

      def check_policy_project(result)
        @policy_configuration = project.security_orchestration_policy_configuration

        if policy_configuration.present?
          policy_project = policy_configuration.security_policy_management_project
        else
          policy_project_response = ProjectCreateService.new(project: project, current_user: current_user).execute
          if policy_project_response[:status] == :success
            @policy_configuration = project.security_orchestration_policy_configuration
            policy_project = policy_project_response.payload[:policy_project]
          else
            error(policy_project_response[:message], :bad_request)
          end
        end

        success(result.merge(policy_project: policy_project))
      end

      def create_or_update_policy(result)
        policy_hash = policy_configuration.policy_hash
        policy_yaml = policy_yaml(policy_hash)

        if policy_yaml.nil?
          error('Invalid YAML', :bad_request)
        end

        policy_commit_attrs = policy_commit_attrs(policy_yaml)

        commit = if policy_hash.present?
                   ::Files::UpdateService.new(result[:policy_project], current_user, policy_commit_attrs).execute
                 else
                   ::Files::CreateService.new(result[:policy_project], current_user, policy_commit_attrs).execute
                 end

        if commit[:status] == :success
          success(result.merge(commit: commit))
        else
          error(commit[:message], :bad_request)
        end
      end

      def create_merge_request(result)
        merge_request_params = {
          source_branch: branch_name,
          target_branch: policy_configuration.default_branch_or_main,
          title: "Update #{Security::OrchestrationPolicyConfiguration::POLICY_PATH}",
          force_remove_source_branch: "1"
        }
        merge_request = ::MergeRequests::CreateService.new(
          project: result[:policy_project],
          current_user: current_user,
          params: merge_request_params
        ).execute

        if merge_request.persisted?
          success(result.merge(merge_request: merge_request))
        else
          error(merge_request.errors.full_messages.join(','))
        end
      end

      private

      def policy_commit_attrs(policy_yaml)
        {
          commit_message: "Update #{Security::OrchestrationPolicyConfiguration::POLICY_PATH}",
          file_path: Security::OrchestrationPolicyConfiguration::POLICY_PATH,
          file_content: policy_yaml,
          branch_name: branch_name,
          start_branch: policy_configuration.default_branch_or_main
        }
      end

      def branch_name
        @branch_name ||= "update-policy-#{Time.now.to_i}"
      end

      def policy_yaml(policy_hash)
        policies = ((policy_hash && policy_hash[:scan_execution_policy]) || []) << Gitlab::Config::Loader::Yaml.new(params[:policy_yaml]).load!

        final_yaml = YAML.dump({ scan_execution_policy: policies }.deep_stringify_keys)

        final_yaml if policy_configuration.policy_configuration_valid?(final_yaml)
      end

      attr_reader :project, :policy_configuration
    end
  end
end
