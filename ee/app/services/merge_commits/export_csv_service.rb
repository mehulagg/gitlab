# frozen_string_literal: true

module MergeCommits
  class ExportCsvService
    TARGET_FILESIZE = 15_000_000 # file size restricted to 15MB

    def initialize(current_user, group)
      @current_user = current_user
      @group = group
    end

    def csv_data
      csv_builder.render(TARGET_FILESIZE)
    end

    private

    attr_reader :current_user, :group

    def csv_builder
      @csv_builder ||= CsvBuilder.new(data, header_to_value_hash)
    end

    def data
      MergeRequestsFinder
        .new(current_user, finder_options)
        .execute
        .preload_author
        .preload_approved_by_users
        .preload_target_project
        .preload_metrics([:merged_by])
    end

    def finder_options
      {
        group_id: group.id,
        state: 'merged'
      }
    end

    def header_to_value_hash
      {
        'Merge Commit' => 'merge_commit_sha',
        'Author' => -> (merge_request) { merge_request.author&.name },
        'Merge Request' => 'id',
        'Merged By' => -> (merge_request) { merge_request.metrics&.merged_by&.name },
        'Pipeline' => -> (merge_request) { merge_request.metrics&.pipeline_id },
        'Group' => -> (merge_request) { merge_request.project&.namespace&.name },
        'Project' => -> (merge_request) { merge_request.project&.name },
        'Approver(s)' => -> (merge_request) { merge_request.approved_by_users.map(&:name).sort.join(" | ") }
      }
    end
  end
end
