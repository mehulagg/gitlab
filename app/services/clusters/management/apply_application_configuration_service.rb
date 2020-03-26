# frozen_string_literal: true

module Clusters
  module Management
    class ApplyApplicationConfigurationService < BaseService
      include Gitlab::Utils::StrongMemoize

      CONFIGURATION_FILE_PATH = '.gitlab/managed-apps/config.yaml'

      attr_reader :cluster, :last_seen_ref

      def initialize(cluster, current_user:, last_seen_ref:)
        @cluster = cluster
        @project = cluster.management_project
        @current_user = current_user
        @last_seen_ref = last_seen_ref
      end

      def execute
        unless can_apply_configuration?
          return error _('Cluster management project not configured')
        end

        if conflicting_ref?
          return error _('Last seen ref does not match cluster management project')
        end

        unless cluster.make_committing
          return error _('Operation already in progress')
        end

        result = create_commit!

        if result[:status] == :success
          cluster.make_applying!

          result
        else
          error result[:message]
        end
      end

      private

      def can_apply_configuration?
        project.present? && Feature.enabled?(:ci_managed_cluster_applications)
      end

      def conflicting_ref?
        applied_ref = project.commit(target_branch)

        applied_ref.present? && applied_ref != last_seen_ref
      end

      def error(message)
        cluster.make_errored!(message)

        super
      end

      def existing_project_configuration
        strong_memoize(:existing_project_configuration) do
          blob = project.repository.blob_at(target_branch, CONFIGURATION_FILE_PATH)

          if blob.present?
            YAML.safe_load(blob.data.to_s)
          else
            {}
          end
        end
      end

      def cluster_applications_configuration
        applications = cluster.applications.select(&:helmfile_install_supported?)
        applications.map(&:helmfile_configuration).reduce(&:merge)
      end

      def create_commit!
        service = existing_project_configuration.present? ? Files::UpdateService : Files::CreateService

        service.new(project, current_user, commit_params).execute
      rescue Psych::SyntaxError
        error _('Invalid configuration file')
      end

      def commit_params
        {
          file_path: CONFIGURATION_FILE_PATH,
          commit_message: _('Update cluster management project'),
          file_content: existing_project_configuration.deep_merge(cluster_applications_configuration).to_yaml,
          branch_name: target_branch,
          start_branch: target_branch
        }
      end

      def target_branch
        project.default_branch
      end
    end
  end
end
