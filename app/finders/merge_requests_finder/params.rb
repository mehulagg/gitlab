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
    def reviewer
      strong_memoize(:reviewers) do
        if reviewer_id?
          User.find_by(id: params[:reviewer_id])
        elsif reviewer_username?
          User.find_by(username: params[:reviewer_username])
        else
          nil
        end
      end
    end
    # rubocop: enable CodeReuse/ActiveRecord
  end
end
