# frozen_string_literal: true

module EE
  module IssueLink
    extend ActiveSupport::Concern

    prepended do
      after_create :refresh_blocking_issue_cache
      after_destroy :refresh_blocking_issue_cache
    end

    class_methods do
      def inverse_link_type(type)
        case type
        when ::IssueLink::TYPE_BLOCKS
          ::IssueLink::TYPE_IS_BLOCKED_BY
        when ::IssueLink::TYPE_IS_BLOCKED_BY
          ::IssueLink::TYPE_BLOCKS
        else
          type
        end
      end

      def blocked_issue_ids(issue_ids)
        blocked_and_blocking_issues_union(issue_ids).pluck(:blocked_issue_id)
      end

      def blocking_issue_ids_for(issue)
        blocked_and_blocking_issues_union(issue.id).pluck(:blocking_issue_id)
      end

      def blocked_and_blocking_issues_union(issue_ids)
        from_union([
          blocked_or_blocking_issues(issue_ids, ::IssueLink::TYPE_BLOCKS),
          blocked_or_blocking_issues(issue_ids, ::IssueLink::TYPE_IS_BLOCKED_BY)
        ])
      end

      def blocked_or_blocking_issues(issue_ids, link_type)
        if link_type == ::IssueLink::TYPE_BLOCKS
          blocked_key = :target_id
          blocking_key = :source_id
        else
          blocked_key = :source_id
          blocking_key = :target_id
        end

        select("#{blocked_key} as blocked_issue_id, #{blocking_key} as blocking_issue_id")
          .where(link_type: link_type).where(blocked_key => issue_ids)
          .joins("INNER JOIN issues ON issues.id = issue_links.#{blocking_key}")
          .where('issues.state_id' => ::Issuable::STATE_ID_MAP[:opened])
      end

      def blocking_issues_for_collection(issues_ids)
        open_state_id = ::Issuable::STATE_ID_MAP[:opened]

        from_union([
          select("COUNT(CASE WHEN issues.state_id = #{open_state_id} then 1 else null end), issue_links.source_id AS blocking_issue_id")
            .joins(:target)
            .where(link_type: ::IssueLink::TYPE_BLOCKS)
            .where(source_id: issues_ids)
            .group(:blocking_issue_id),
          select("COUNT(CASE WHEN issues.state_id = #{open_state_id} then 1 else null end), issue_links.target_id AS blocking_issue_id")
            .joins(:source)
            .where(link_type: ::IssueLink::TYPE_IS_BLOCKED_BY)
            .where(target_id: issues_ids)
            .group(:blocking_issue_id)
        ], remove_duplicates: false).select('blocking_issue_id, SUM(count) AS count').group('blocking_issue_id')
      end

      def blocked_issues_for_collection(issues_ids)
        from_union([
          select('COUNT(*), issue_links.source_id AS blocked_issue_id')
            .joins(:target)
            .where(issues: { state_id: ::Issue.available_states[:opened] })
            .where(link_type: ::IssueLink::TYPE_IS_BLOCKED_BY)
            .where(source_id: issues_ids)
            .group(:blocked_issue_id),
          select('COUNT(*), issue_links.target_id AS blocked_issue_id')
            .joins(:source)
            .where(issues: { state_id: ::Issue.available_states[:opened] })
            .where(link_type: ::IssueLink::TYPE_BLOCKS)
            .where(target_id: issues_ids)
            .group(:blocked_issue_id)
        ], remove_duplicates: false).select('blocked_issue_id, SUM(count) AS count').group('blocked_issue_id')
      end

      def blocking_issues_count_for(issue)
        blocking_issues_for_collection(issue.id)[0]&.count.to_i
      end
    end

    private

    def blocking_issue
      case link_type
      when ::IssueLink::TYPE_BLOCKS then source
      when ::IssueLink::TYPE_IS_BLOCKED_BY then target
      end
    end

    def refresh_blocking_issue_cache
      blocking_issue&.update_blocking_issues_count!
    end
  end
end
