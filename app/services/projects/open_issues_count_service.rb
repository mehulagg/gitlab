# frozen_string_literal: true

module Projects
  # Service class for counting and caching the number of open issues of a
  # project.
  class OpenIssuesCountService < Projects::CountService
    include Gitlab::Utils::StrongMemoize

    # Cache keys used to store issues count
    # TOTAL_COUNT_KEY includes confidential and hidden issues (admin)
    # TOTAL_COUNT_WITHOUT_HIDDEN_KEY includes confidential issues but not hidden issues (reporter)
    # PUBLIC_COUNT_WITHOUT_HIDDEN_KEY does not include confidential or hidden issues (guest)
    TOTAL_COUNT_KEY = 'open_issues_including_hidden_count'
    TOTAL_COUNT_WITHOUT_HIDDEN_KEY = 'open_issues_without_hidden_count'
    PUBLIC_COUNT_WITHOUT_HIDDEN_KEY = 'open_public_issues_without_hidden_count'

    def initialize(project, user = nil)
      @user = user

      super(project)
    end

    def cache_key_name
      if user_is_admin?
        TOTAL_COUNT_KEY
      else
        public_only? ? PUBLIC_COUNT_WITHOUT_HIDDEN_KEY : TOTAL_COUNT_WITHOUT_HIDDEN_KEY
      end
    end

    def user_is_admin?
      @user&.can_admin_all_resources?
    end

    def public_only?
      !user_is_at_least_reporter?
    end

    def relation_for_count
      self.class.query(@project, public_only: public_only?)
    end

    def user_is_at_least_reporter?
      strong_memoize(:user_is_at_least_reporter) do
        @user && @project.team.member?(@user, Gitlab::Access::REPORTER)
      end
    end

    def public_count_cache_key
      cache_key(PUBLIC_COUNT_KEY)
    end

    def total_count_cache_key
      cache_key(TOTAL_COUNT_KEY)
    end

    # rubocop: disable CodeReuse/ActiveRecord
    def refresh_cache(&block)
      if block_given?
        super(&block)
      else

        with_hidden_issues = self.class.query(@project, include_hidden: true)
        without_hidden_issues = self.class.query(@project, include_hidden: false)

        without_hidden_count_grouped_by_confidential = without_hidden_issues.group(:confidential).count

        total_public_without_hidden_count = without_hidden_count_grouped_by_confidential[false] || 0
        total_confidential_without_hidden_count = without_hidden_count_grouped_by_confidential[true] || 0

        update_cache_for_key(total_count_cache_key) do
          with_hidden_issues.count
        end

        update_cache_for_key(public_count_without_hidden_cache_key) do
          total_public_without_hidden_count
        end

        update_cache_for_key(total_count_without_hidden_cache_key) do
          total_public_without_hidden_count + total_confidential_without_hidden_count
        end
      end
    end
    # rubocop: enable CodeReuse/ActiveRecord

    # We only show total issues count for admins who are allowed to view hidden issues.
    # We also only show issues count including confidential for reporters, who are allowed to view confidential issues.
    # This will still show a discrepancy on issues number but should be less than before.
    # Check https://gitlab.com/gitlab-org/gitlab-foss/issues/38418 description.
    # rubocop: disable CodeReuse/ActiveRecord
    def self.query(projects, include_hidden: true)
      issues_filtered_by_type = Issue.opened.with_issue_type(Issue::TYPES_FOR_LIST)

      if include_hidden
        issues_filtered_by_type.where(project: projects)
      else
        issues_filtered_by_type.where(project: projects).joins(:author).where("users.state != 'banned'")
      end
    end
    # rubocop: enable CodeReuse/ActiveRecord
  end
end
