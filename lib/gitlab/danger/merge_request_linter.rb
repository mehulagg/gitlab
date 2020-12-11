# frozen_string_literal: true

module Gitlab
  module Danger
    class MergeRequestLinter < CommitLinter
      RUN_AS_IF_FOSS = 'RUN AS-IF-FOSS'

      private

      def subject_too_long?
        subject_without_meta_info = subject.gsub(/\[?#{RUN_AS_IF_FOSS}\]?/, '')

        line_too_long?(subject_without_meta_info)
      end
    end
  end
end
