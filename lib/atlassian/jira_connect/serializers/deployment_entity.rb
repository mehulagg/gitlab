# frozen_string_literal: true

module Atlassian
  module JiraConnect
    module Serializers
      class DeploymentEntity < Grape::Entity
        include Gitlab::Routing

        format_with(:iso8601, &:iso8601)

        expose :schema_version, as: :schemaVersion
        expose :iid, as: :deploymentSequenceNumber
        expose :update_sequence_id, as: :updateSequenceNumber
        expose :display_name, as: :displayName
        expose :associations
        expose :url
        expose :label
        expose :state
        expose :updated_at, as: :lastUpdated, format_with: :iso8601
        expose :issue_keys, as: :issueKeys
        expose :test_info, as: :testInfo
        expose :references

        def issue_keys
          # extract Jira issue keys from either the source branch/ref or the
          # merge request title.
          @issue_keys ||= begin
                            object.merge_requests.flat_map do |mr|
                              src = "#{mr.source_branch} #{mr.title}"
                              JiraIssueKeyExtractor.new(src).issue_keys
                            end.uniq
                          end
        end

        private

        alias_method :deployment, :object
        delegate :project, to: :object

        def associations
          [
            {
              associationType: :issueIdOrKeys,
              values: issue_keys
            }
          ]
        end

        def display_name
          "Deployment #{deployment.name} no. #{deployment.iid} of #{deployment.project.full_path}"
        end

        def label
          "Deployment #{deployment.updated_at}-#{deployment.sha}"
        end

        def url
          project_deployment_url(project, deployment)
        end

        def state
          case deployment.status
          when 'scheduled', 'created', 'pending', 'preparing', 'waiting_for_resource' then 'pending'
          when 'running' then 'in_progress'
          when 'success' then 'successful'
          when 'failed' then 'failed'
          when 'canceled', 'skipped' then 'cancelled'
          else
            'unknown'
          end
        end

        def schema_version
          '1.0'
        end

        def references
          ref = pipeline.source_ref

          [{
            commit: { id: pipeline.sha, repositoryUri: project_url(project) },
            ref: { name: ref, uri: project_commits_url(project, ref) }
          }]
        end

        def update_sequence_id
          options[:update_sequence_id] || Client.generate_update_sequence_id
        end
      end
    end
  end
end
