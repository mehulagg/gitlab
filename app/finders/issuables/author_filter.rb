module Issuables
  class AuthorFilter < BaseFilter
    def filter
      filtered = by_author(issuables)
      by_negated_author(filtered)
    end

    private

    def by_author(issuables)
      if no_author?
        issuables.where(author_id: nil)
      elsif params[:author_id].present?
        issuables.where(author_id: params[:author_id])
      elsif params[:author_username].present?
        issuables.where(author_id: authors_by_username(params[:author_username]))
      else
        issuables
      end
    end

    def by_negated_author(issuables)
      return issuables unless not_params.present? && not_filters_enabled?

      if not_params[:author_id].present?
        issuables.where.not(author_id: not_params[:author_id])
      elsif not_params[:author_username].present?
        issuables.where.not(author_id: authors_by_username(not_params[:author_username]))
      else
        issuables
      end
    end

    def no_author?
      # author_id takes precedence over author_username
      params[:author_id] == NONE || params[:author_username] == NONE
    end

    def authors_by_username(usernames)
      User.where(username: usernames)
    end
  end
end
