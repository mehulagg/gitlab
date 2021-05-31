# frozen_string_literal: true

module Gitlab
  module Diff
    module FileCollection
      class Commit < Base
        def initialize(commit, diff_options:)
          super(commit,
            project: commit.project,
            diff_options: diff_options,
            diff_refs: commit.diff_refs)
        end

        def raw_diff_files(sorted: false)
          strong_memoize(:"raw_diff_files_#{sorted}") do
            collection = diffs.decorate! { |diff| decorate_diff!(diff) }
            collection = sort_diffs(collection) if sorted
            collection.unshift(diff_file)

            collection
          end
        end

        private

        def diff_file
          @diff_file ||=
            Gitlab::Diff::CommitMsg.new(as_diff,
                                        repository: project.repository,
                                        diff_refs: diff_refs,
                                        fallback_diff_refs: fallback_diff_refs,
                                        stats: stats)
        end

        def as_diff
          @as_diff ||= Gitlab::Git::CommitMsgAsDiff.new(diffable)
        end

        def stats
          @stats ||= Gitaly::DiffStats.new(path: "COMMIT_MSG",
                                           old_path: "",
                                           additions: as_diff.line_count,
                                           deletions: 0)
        end
      end
    end
  end
end
