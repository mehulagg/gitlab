# frozen_string_literal: true

module EE
  module Gitlab
    module BackgroundMigration
      module SyncBlockingIssuesCount
        extend ::Gitlab::Utils::Override

        override :perform
        def perform(start_id, end_id)
          ActiveRecord::Base.connection.execute <<~SQL
            UPDATE issues
            SET blocking_issues_count = grouped_counts.count
            FROM
              (
                SELECT blocking_issue_id, SUM(blocked_count) AS count
                FROM  (
                          SELECT COUNT(*) AS blocked_count, issue_links.source_id AS blocking_issue_id
                          FROM issue_links
                          INNER JOIN issues ON issue_links.source_id = issues.id
                          WHERE issue_links.link_type = 1
                          AND issues.state_id = 1
                          AND issues.blocking_issues_count = 0
                          AND issue_links.source_id BETWEEN #{start_id} AND #{end_id}
                          GROUP BY blocking_issue_id HAVING COUNT(*) > 0
                UNION ALL
                          SELECT COUNT(*) AS blocked_count, issue_links.target_id AS blocking_issue_id
                          FROM issue_links
                          INNER JOIN issues ON issue_links.target_id = issues.id
                          WHERE issue_links.link_type = 2
                          AND issues.state_id = 1
                          AND issues.blocking_issues_count = 0
                          AND issue_links.target_id BETWEEN #{start_id} AND #{end_id}
                          GROUP BY blocking_issue_id HAVING COUNT(*) > 0
                        ) blocking_counts
            GROUP BY  blocking_issue_id
               ) AS grouped_counts
            WHERE issues.blocking_issues_count = 0
            AND issues.state_id = 1
            AND issues.id = grouped_counts.blocking_issue_id
            AND grouped_counts.count > 0
          SQL
        end
      end
    end
  end
end
