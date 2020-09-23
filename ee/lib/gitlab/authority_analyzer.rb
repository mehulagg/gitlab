# frozen_string_literal: true

module Gitlab
  class AuthorityAnalyzer
    COMMITS_TO_CONSIDER = 25
    FILES_TO_CONSIDER = 100

    def initialize(merge_request, skip_user)
      @merge_request = merge_request
      @skip_user = skip_user
      @users = Hash.new(0)
    end

    def calculate
      involved_users

      # Sort most active users from hash like: {user1: 2, user2: 6}
      @users.sort_by { |user, count| -count }.map(&:first)
    end

    private

    def involved_users
      @repo = @merge_request.target_project.repository

      @repo.commits(@merge_request.target_branch, path: list_of_involved_files, limit: COMMITS_TO_CONSIDER).each do |commit|
        if commit.author && commit.author != @skip_user
          @users[commit.author] += 1
        end
      end
    end

    def list_of_involved_files
      @merge_request.modified_paths.first(FILES_TO_CONSIDER)
    end
  end
end
