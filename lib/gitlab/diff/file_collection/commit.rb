# frozen_string_literal: true

module Gitlab
  module Diff
    module FileCollection
      class Commit < Base
        def initialize(commit, diff_options:, sort_diff_files: false)
          super(commit,
            project: commit.project,
            diff_options: diff_options,
            diff_refs: commit.diff_refs,
            sort_diff_files: sort_diff_files)
        end
      end
    end
  end
end
