module Issuables
  class AuthorFilter < BaseFilter
    def filter
      filtered = by_author(issuables)
      filtered = by_author_union(filtered)
      by_negated_author(filtered)
    end

    private

    def by_author(issuables)
      if params[:author_id].present?
        issuables.where(author_id: params[:author_id])
      elsif params[:author_username].present?
        issuables.where(author_id: authors_by_username(params[:author_username]))
      else
        issuables
      end
    end

    def by_author_union(issuables)
      return issuables unless or_filters_enabled? && or_params&.fetch(:author_username).present?

      issuables.where(author_id: authors_by_username(or_params[:author_username]))
    end

    def by_negated_author(issuables)
      return issuables unless not_filters_enabled? && not_params.present?

      if not_params[:author_id].present?
        issuables.where.not(author_id: not_params[:author_id])
      elsif not_params[:author_username].present?
        issuables.where.not(author_id: authors_by_username(not_params[:author_username]))
      else
        issuables
      end
    end

    def authors_by_username(usernames)
      User.where(username: usernames)
    end
  end
end
