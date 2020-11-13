# frozen_string_literal: true

class MergeRequestsFinder
  class Params < IssuableFinder::Params
    def filter_by_no_reviewer?
      params[:reviewer_id].to_s.downcase == FILTER_NONE
    end

    def filter_by_any_reviewer?
      params[:reviewer_id].to_s.downcase == FILTER_ANY
    end

    # rubocop: disable CodeReuse/ActiveRecord
    def reviewers
      strong_memoize(:reviewers) do
        if reviewer_id?
          User.where(id: params[:reviewer_id])
        elsif reviewer_username?
          User.where(username: params[:reviewer_username])
        else
          User.none
        end
      end
    end
    # rubocop: enable CodeReuse/ActiveRecord

    def reviewer
      reviewers.first
    end
  end
end
