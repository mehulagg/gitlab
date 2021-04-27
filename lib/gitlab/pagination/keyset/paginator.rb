# frozen_string_literal: true

module Gitlab
  module Pagination
    module Keyset
      class Paginator
        NEXT_PAGE = 'next'
        PREV_PAGE = 'previous'

        def initialize(scope:, cursor:, per_page: 5)
          @keyset_scope = build_scope(scope)
          @order = Gitlab::Pagination::Keyset::Order.extract_keyset_order_object(@keyset_scope)
          @cursor_attributes = decode_cursor_attributes(cursor)
        end

        # rubocop: disable CodeReuse/ActiveRecord
        def records
          @records ||= begin
            recs = if paginate_backwards?
                     reversed = @order.reversed_order
                     reversed.apply_cursor_conditions(keyset_scope, @cursor_attributes).reorder(reversed).limit(5 + 1).to_a.reverse
                   else
                     @order.apply_cursor_conditions(keyset_scope, @cursor_attributes).limit(5 + 1).to_a
                   end

            if recs.size == 6
              @has_next_page = true
              if paginate_backwards?
                recs.last(5)
              else
                recs.first(5)
              end
            else
              recs
            end
          end
        end
        # rubocop: enable CodeReuse/ActiveRecord

        def to_a
          records
        end

        def empty?
          records.empty?
        end

        def has_next_page?
          records

          if @last_page
            false
          elsif paginate_forward?
            @has_next_page || @last_page
          elsif paginate_backwards?
            true
          end
        end

        def has_previous_page?
          records

          if @first_page
            false
          elsif paginate_backwards?
            @has_next_page || @first_page
          elsif paginate_forward?
            true
          end
        end

        def cursor_for_next_page
          if has_next_page?
            data = @order.cursor_attributes_for_node(records.last)
            data[:_kd] = 'n'
            Base64.urlsafe_encode64(Gitlab::Json.dump(data))
          else
            nil
          end
        end

        def cursor_for_previous_page
          if records.any? && !@first_page
            data = @order.cursor_attributes_for_node(records.first)
            data[:_kd] = 'p'
            Base64.urlsafe_encode64(Gitlab::Json.dump(data))
          end
        end

        def cursor_for_first_page
          Base64.urlsafe_encode64(Gitlab::Json.dump({ _kd: 'n' }))
        end

        def cursor_for_last_page
          Base64.urlsafe_encode64(Gitlab::Json.dump({ _kd: 'p' }))
        end

        def paginate_backwards?
          @direction == 'p'
        end

        def paginate_forward?
          @direction == 'n'
        end

        private

        attr_reader :keyset_scope

        def decode_cursor_attributes(cursor)
          if cursor.blank? || cursor == 'first'
            @first_page = true
            @direction = 'n'
            {}
          else
            data = Gitlab::Json.parse(Base64.urlsafe_decode64(cursor))
            @direction = data.delete('_kd')
            if data.blank?
              if @direction == 'n'
                @first_page = true
              elsif @direction == 'p'
                @last_page = true
              end
            end

            data
          end
        end

        def build_scope(scope)
          Gitlab::Pagination::Keyset::SimpleOrderBuilder.build(scope).first
        end
      end
    end
  end
end
