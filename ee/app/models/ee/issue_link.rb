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
        blocked_or_blocking_issues(issue_ids).pluck(:target_id)
      end

      def blocking_issue_ids_for(issue)
        blocked_or_blocking_issues(issue.id).pluck(:source_id)
      end

      def blocked_or_blocking_issues(issue_ids)
        where(link_type: ::IssueLink::TYPE_BLOCKS).where(target_id: issue_ids)
          .joins(:source)
          .where(issues: { state_id: ::Issue.available_states[:opened] })
      end

      def blocking_issues_for_collection(issues_ids)
        open_state_id = ::Issuable::STATE_ID_MAP[:opened]

        select("COUNT(CASE WHEN issues.state_id = #{open_state_id} then 1 else null end), issue_links.source_id AS blocking_issue_id")
          .joins(:target)
          .where(link_type: ::IssueLink::TYPE_BLOCKS, source_id: issues_ids)
          .group(:blocking_issue_id)
      end

      def blocked_issues_for_collection(issues_ids)
        select('COUNT(*), issue_links.target_id AS blocked_issue_id')
          .joins(:source)
          .where(issues: { state_id: ::Issue.available_states[:opened] })
          .where(link_type: ::IssueLink::TYPE_BLOCKS)
          .where(target_id: issues_ids)
          .group(:blocked_issue_id)
      end

      def blocking_issues_count_for(issue)
        blocking_issues_for_collection(issue.id)[0]&.count.to_i
      end
    end

    private

    def blocking_issue
      source if link_type == ::IssueLink::TYPE_BLOCKS
    end

    def refresh_blocking_issue_cache
      blocking_issue&.update_blocking_issues_count!
    end
  end
end
