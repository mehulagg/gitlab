# frozen_string_literal: true

module Gitlab
  module CodeOwners
    FILE_NAME = 'CODEOWNERS'
    FILE_PATHS = [FILE_NAME, "docs/#{FILE_NAME}", ".gitlab/#{FILE_NAME}"].freeze

    def self.for_blob(project, blob)
      if project.feature_available?(:code_owners)
        Loader.new(project, blob.commit_id, blob.path).members
      else
        []
      end
    end

    # @param merge_request [MergeRequest]
    # @param merge_request_diff [MergeRequestDiff]
    #   Find code owners entries at a particular MergeRequestDiff.
    #   Assumed to be the most recent one if not provided.
    def self.entries_for_merge_request(merge_request, merge_request_diff: nil)
      return [] unless merge_request.project.feature_available?(:code_owners)

      loader_for_merge_request(merge_request, merge_request_diff)&.entries || []
    end

    def self.loader_for_merge_request(merge_request, merge_request_diff)
      return if merge_request.source_project.nil? || merge_request.source_branch.nil?
      return unless merge_request.target_project.feature_available?(:code_owners)

      Loader.new(
        merge_request.target_project,
        merge_request.target_branch,
        paths_for_merge_request(merge_request, merge_request_diff)
      )
    end
    private_class_method :loader_for_merge_request

    def self.paths_for_merge_request(merge_request, merge_request_diff)
      # Because MergeRequest#modified_paths is limited to only returning 1_000
      #   records, if the diff_size is more than 1_000, we need to fall back to
      #   the MUCH slower method of using Repository#diff_stats, which isn't
      #   subject to the same limit.
      #
      if oversized_merge_request?(merge_request, merge_request_diff)
        slow_path_lookup(merge_request, merge_request_diff)
      else
        fast_path_lookup(merge_request, merge_request_diff)
      end
    end
    private_class_method :paths_for_merge_request

    def self.oversized_merge_request?(merge_request, merge_request_diff)
      mrd_to_check_for_overflow = merge_request_diff || merge_request.merge_request_diff

      mrd_to_check_for_overflow.overflow?
    end
    private_class_method :oversized_merge_request?

    def self.slow_path_lookup(merge_request, merge_request_diff)
      merge_request_diff ||= merge_request.merge_request_diff

      merge_request.project.repository.diff_stats(
        merge_request_diff.base_commit_sha,
        merge_request_diff.head_commit_sha
      ).paths
    end
    private_class_method :slow_path_lookup

    def self.fast_path_lookup(merge_request, merge_request_diff)
      merge_request.modified_paths(past_merge_request_diff: merge_request_diff)
    end
    private_class_method :fast_path_lookup
  end
end
