# frozen_string_literal: true

module Gitlab
  # This class is used by the `gitlab:usage_data:dump_sql` rake tasks to output SQL instead of running it.
  # See https://gitlab.com/gitlab-org/gitlab/-/merge_requests/41091
  class UsageDataNoSql < UsageData
    class << self
      def count(relation, column = nil, *rest)
        -1
      end

      def distinct_count(relation, column = nil, *rest)
        -1
      end

      def estimate_batch_distinct_count(relation, column = nil, *rest)
        -1
      end
    end
  end
end
