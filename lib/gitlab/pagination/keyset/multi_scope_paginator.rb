# frozen_string_literal: true

module Gitlab
  module Pagination
    module Keyset
      class MultiScopePaginator
        include Gitlab::Pagination::Keyset::Paginatable

        attr_reader :sort_lambda, :paginators

        def initialize(scopes: [], cursor: nil, sort_lambda: nil, per_page: 20, cursor_converter: Base64CursorConverter, direction_key: :_kd)
          setup_pagination_variables(cursor, per_page, cursor_converter, direction_key)

          @sort_lambda = sort_lambda
          @paginators = scopes.map do |scope|
            Gitlab::Pagination::Keyset::Paginator.new(scope: scope.call, cursor: cursor, per_page: per_page)
          end
        end

        override :records
        # rubocop: disable CodeReuse/ActiveRecord
        def records
          @records ||= begin
            items = paginators.flat_map(&:records).sort_by(&sort_lambda)
            items = paginate_backward? ? items.last(per_page_plus_one) : items.take(per_page_plus_one)

            state.has_another_page = items.size == per_page_plus_one
            items.pop if paginate_forward?
            items.shift if paginate_backward?
            items
          end
        end
        # rubocop: enable CodeReuse/ActiveRecord

        override :order
        def order
          @paginators.first.order
        end
      end
    end
  end
end
