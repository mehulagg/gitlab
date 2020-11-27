# frozen_string_literal: true

module Analytics
  module DevopsAdoption
    class SnapshotCalculator
      attr_reader :segment, :recorded_at, :start_time

      ADOPTION_FLAGS = %i[issue_opened merge_request_opened merge_request_approved runner_configured pipeline_succeeded deploy_succeeded security_scan_succeeded].freeze

      def initialize(segment:, recorded_at: Time.zone.now)
        @segment = segment
        @recorded_at = recorded_at
        @start_time = Analytics::DevopsAdoption::Snapshot.new(recorded_at: recorded_at).start_time
      end

      def calculate
        params = { recorded_at: recorded_at, segment: segment }

        ADOPTION_FLAGS.each do |flag|
          params[flag] = send(flag) # rubocop:disable GitlabSecurity/PublicSend
        end

        params
      end

      private

      def snapshot_groups
        @snapshot_groups ||= Gitlab::ObjectHierarchy.new(segment.groups).base_and_descendants
      end

      def snapshot_projects
        @snapshot_projects ||= Project.in_namespace(snapshot_groups)
      end

      def snapshot_merge_requests
        @snapshot_merge_requests ||= MergeRequest.of_projects(snapshot_projects)
      end

      def issue_opened
        Issue.in_projects(snapshot_projects).created_before(recorded_at).created_after(start_time).count > 0
      end

      def merge_request_opened
        snapshot_merge_requests.created_before(recorded_at).created_after(start_time).count > 0
      end

      # rubocop: disable CodeReuse/ActiveRecord
      def merge_request_approved
        Approval.joins(:merge_request).merge(snapshot_merge_requests).created_before(recorded_at).created_after(start_time).count > 0
      end
      # rubocop: enable CodeReuse/ActiveRecord

      def runner_configured
        Ci::Runner.active.belonging_to_group_or_project(snapshot_groups, snapshot_projects).count > 0
      end

      def pipeline_succeeded
        Ci::Pipeline.success.for_project(snapshot_projects).updated_before(recorded_at).updated_after(start_time).count > 0
      end

      def deploy_succeeded
        Deployment.for_project(snapshot_projects).updated_before(recorded_at).updated_after(start_time).count > 0
      end

      # rubocop: disable CodeReuse/ActiveRecord
      def security_scan_succeeded
        Security::Scan.joins(:build).merge(Ci::Build.for_project(snapshot_projects)).created_before(recorded_at).created_after(start_time).count > 0
      end
      # rubocop: enable CodeReuse/ActiveRecord
    end
  end
end
