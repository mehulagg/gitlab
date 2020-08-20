# frozen_string_literal: true

module Suggestions
  class ApplyService < ::BaseService
    def initialize(current_user, *suggestions)
      @current_user = current_user
      @suggestion_set = Gitlab::Suggestions::SuggestionSet.new(suggestions)
    end

    def execute
      if suggestion_set.valid?
        result
      else
        error(suggestion_set.error_message)
      end
    end

    private

    attr_reader :current_user, :suggestion_set

    def result
      multi_service.execute.tap do |result|
        update_suggestions(result)
      end
    end

    def update_suggestions(result)
      return unless result[:status] == :success

      Suggestion.id_in(suggestion_set.suggestions)
        .update_all(commit_id: result[:result], applied: true)
    end

    def author
      Gitlab::Git::User.from_gitlab(suggestion_set.authors.first) if suggestion_set.authors.one?
    end

    def multi_service
      params = {
        commit_message: commit_message,
        branch_name: suggestion_set.branch,
        start_branch: suggestion_set.branch,
        actions: suggestion_set.actions,
        author_name: author&.name,
        author_email: author&.email
      }

      ::Files::MultiService.new(suggestion_set.project, current_user, params)
    end

    def commit_message
      Gitlab::Suggestions::CommitMessage.new(current_user, suggestion_set).message
    end
  end
end
