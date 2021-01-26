# frozen_string_literal: true

module Analytics
  module DevopsAdoption
    class SnapshotCalculator
      attr_reader :segment, :range_end, :range_start, :snapshot

      ADOPTION_FLAGS = %i[issue_opened merge_request_opened merge_request_approved runner_configured pipeline_succeeded deploy_succeeded security_scan_succeeded].freeze

      def initialize(segment:, range_end:, snapshot: nil)
        @segment = segment
        @range_end = range_end
        @range_start = Snapshot.new(end_time: range_end).start_time
        @snapshot = snapshot
      end

      def calculate
        params = { recorded_at: Time.zone.now, end_time: range_end, segment: segment }

        ADOPTION_FLAGS.each do |flag|
          params[flag] = snapshot&.public_send(flag) || send(flag) # rubocop:disable GitlabSecurity/PublicSend
        end

        params
      end

      private

      def snapshot_groups
        @snapshot_groups ||= segment.namespace.self_and_descendants
      end

      # rubocop: disable CodeReuse/ActiveRecord
      def snapshot_project_ids
        @snapshot_project_ids ||= Project.in_namespace(snapshot_groups).pluck(:id)
      end
      # rubocop: enable CodeReuse/ActiveRecord

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
    end
  end
end
