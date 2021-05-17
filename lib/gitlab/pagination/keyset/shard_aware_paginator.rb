# frozen_string_literal: true

# {
module Gitlab
  module Pagination
    module Keyset
      class ShardAwarePaginator < Gitlab::Pagination::Keyset::Paginator
        def initialize(scopes: [], cursor: nil, per_page: 20, sort_lambda: nil, cursor_converter: Base64CursorConverter, direction_key: :_kd)
          @scopes = scopes
          @has_another_page = false
          @at_last_page = false
          @at_first_page = false
          @per_page = per_page
          @sort_lambda = sort_lambda
          @cursor_converter = cursor_converter
          @cursor_attributes = decode_cursor_attributes(cursor)
          @direction_key = direction_key

          @paginators = scopes.map do |scope, i|
            Gitlab::Pagination::Keyset::Paginator.new(scope: scope.call, cursor: cursor, per_page: per_page)
          end

          set_paingation_helper_flags!
        end

        # rubocop: disable CodeReuse/ActiveRecord
        def records
          @records ||= begin
            items = if paginate_backwards?
                      @paginators.flat_map(&:records).sort_by(&@sort_lambda).reverse.take(per_page + 1)
                    else
                      @paginators.flat_map(&:records).sort_by(&@sort_lambda).take(per_page + 1)
                    end

            if items.size == per_page_plus_one
              @has_another_page = true

              paginate_forward? ? items.first(per_page) : items.last(per_page)
            else
              @has_another_page = false
              items
            end
          end
        end
        # rubocop: enable CodeReuse/ActiveRecord

        def cursor_for_next_page
          if has_next_page?
            data = @paginators.first.send(:order).cursor_attributes_for_node(records.last)
            data[direction_key] = FORWARD_DIRECTION
            cursor_converter.dump(data)
          else
            nil
          end
        end

        def cursor_for_previous_page
          if has_previous_page?
            data = @paginators.first.send(:order).cursor_attributes_for_node(records.last)
            data[direction_key] = BACKWARD_DIRECTION
            cursor_converter.dump(data)
          end
        end
      end
    end
  end
end
