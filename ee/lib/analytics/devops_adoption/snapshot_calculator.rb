# frozen_string_literal: true

module Analytics
  module DevopsAdoption
    class SnapshotCalculator
      attr_reader :enabled_namespace, :range_end, :range_start, :snapshot

      def initialize(enabled_namespace:, range_end:, snapshot: nil)
        @enabled_namespace = enabled_namespace
        @range_end = range_end
        @range_start = Snapshot.new(end_time: range_end).start_time
        @snapshot = snapshot
      end

      def calculate
        params = { recorded_at: Time.zone.now, end_time: range_end, namespace: enabled_namespace.namespace }

        Snapshot::BOOLEAN_METRICS.each do |metric|
          params[metric] = snapshot&.public_send(metric) || send(metric) # rubocop:disable GitlabSecurity/PublicSend
        end

        Snapshot::NUMERIC_METRICS.each do |metric|
          params[metric] = send(metric) # rubocop:disable GitlabSecurity/PublicSend
        end

        params
      end

      private

      def snapshot_groups
        @snapshot_groups ||= enabled_namespace.namespace.self_and_descendants
      end

      # rubocop: disable CodeReuse/ActiveRecord
      def snapshot_project_ids
        @snapshot_project_ids ||= snapshot_projects.pluck(:id)
      end
      # rubocop: enable CodeReuse/ActiveRecord

      def snapshot_projects
        @snapshot_projects ||= Project.in_namespace(snapshot_groups)
      end

      def snapshot_merge_requests
        @snapshot_merge_requests ||= MergeRequest.of_projects(snapshot_project_ids)
      end

      def issue_opened
        Issue.in_projects(snapshot_project_ids).created_before(range_end).created_after(range_start).exists?
      end

      def merge_request_opened
        snapshot_merge_requests.created_before(range_end).created_after(range_start).exists?
      end

      # rubocop: disable CodeReuse/ActiveRecord
      def merge_request_approved
        Approval.joins(:merge_request).merge(snapshot_merge_requests).created_before(range_end).created_after(range_start).exists?
      end
      # rubocop: enable CodeReuse/ActiveRecord

      def runner_configured
        Ci::Runner.active.belonging_to_group_or_project(snapshot_groups, snapshot_project_ids).exists?
      end

      def pipeline_succeeded
        Ci::Pipeline.success.for_project(snapshot_project_ids).updated_before(range_end).updated_after(range_start).exists?
      end

      def deploy_succeeded
        Deployment.success.for_project(snapshot_project_ids).updated_before(range_end).updated_after(range_start).exists?
      end

      # rubocop: disable CodeReuse/ActiveRecord
      def security_scan_succeeded
        Security::Scan
          .joins(:build)
          .merge(Ci::Build.for_project(snapshot_project_ids))
          .created_before(range_end)
          .created_after(range_start)
          .exists?
      end
      # rubocop: enable CodeReuse/ActiveRecord

      def total_projects_count
        snapshot_project_ids.count
      end

      def code_owners_used_count
        return unless Feature.enabled?(:analytics_devops_adoption_codeowners, enabled_namespace.namespace, default_enabled: :yaml)

        snapshot_projects.count do |project|
          !Gitlab::CodeOwners::Loader.new(project, project.default_branch || 'HEAD').empty_code_owners?
        end
      end

      # rubocop: disable CodeReuse/ActiveRecord
      def sast_enabled_count
        return unless Feature.enabled?(:analytics_devops_adoption_sastdast, enabled_namespace.namespace, default_enabled: :yaml)

        Ci::JobArtifact.sast_reports
                       .for_project(snapshot_project_ids)
                       .created_in_time_range(from: range_start, to: range_end)
                       .select(:project_id).distinct.count
      end
      # rubocop: enable CodeReuse/ActiveRecord

      # rubocop: disable CodeReuse/ActiveRecord
      def dast_enabled_count
        return unless Feature.enabled?(:analytics_devops_adoption_sastdast, enabled_namespace.namespace, default_enabled: :yaml)

        Ci::JobArtifact.dast_reports
          .for_project(snapshot_project_ids)
          .created_in_time_range(from: range_start, to: range_end)
          .select(:project_id).distinct.count
      end
      # rubocop: enable CodeReuse/ActiveRecord
    end
  end
end
