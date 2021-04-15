# frozen_string_literal: true

module Security
  module CiConfiguration
    class BaseCreateService
      attr_reader :branch_name, :current_user, :project, :params

      def initialize(project, current_user, params)
        @project = project
        @current_user = current_user
        @params = params
        @branch_name = project.repository.next_branch(next_branch)
      end

      def execute
        project.repository.add_branch(current_user, branch_name, project.default_branch)

        attributes_for_commit = attributes

        result = ::Files::MultiService.new(project, current_user, attributes_for_commit).execute

        if result[:status] == :success
          track_event(attributes_for_commit)
          return ServiceResponse.success(payload: { success_path: successful_change_path })
        end

        ServiceResponse.error(message: result[:message])

      rescue Gitlab::Git::PreReceiveError => e
        ServiceResponse.error(message: e.message)
      end

      private

      def attributes
        {
          commit_message: message,
          branch_name: branch_name,
          start_branch: branch_name,
          actions: actions
        }
      end

      def existing_gitlab_ci_content
        @gitlab_ci_yml ||= project.repository.gitlab_ci_yml_for(project.repository.root_ref_sha)
        YAML.safe_load(@gitlab_ci_yml) if @gitlab_ci_yml
      end

      def successful_change_path
        merge_request_params = { source_branch: branch_name, description: description }
        Gitlab::Routing.url_helpers.project_new_merge_request_url(project, merge_request: merge_request_params)
      end

      def track_event(attributes_for_commit)
        action = attributes_for_commit[:actions].first

        Gitlab::Tracking.event(
          self.class.to_s, action[:action], label: action[:default_values_overwritten].to_s
        )
      end
    end
  end
end
